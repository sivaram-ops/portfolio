def call(Map config) {
    pipeline {
        agent any
        
        environment {
            SERVICE_NAME = "${config.serviceName}"
            LANGUAGE = "${config.language}"
            GIT_REPO = "${config.repoUrl}"
            
            // If using Nexus, add your Nexus URL here (e.g., "nexus.stan-ecommerce.com:8083/sivaram0101/...")
            IMAGE_NAME = "sivaram0101/${config.serviceName}-roboshop"
            IMAGE_TAG = "v${env.BUILD_ID}"
            FULL_IMAGE = "${IMAGE_NAME}:${IMAGE_TAG}"
            
            SONAR_HOME = tool 'sonar-scanner'
            OWASP_HOME = tool 'DP-Check'
            MVN_HOME = tool 'maven' 
            
            GITOPS_REPO = "https://github.com/sivaram-ops/roboshop-gitops.git" 
        }

        stages {
            stage('Git Checkout') {
                steps {
                    checkout scm
                }
            }
            
            stage('Docker Lint') {
                when { expression { env.LANGUAGE == 'docker-only' } }
                steps {
                    sh "docker run --rm -i hadolint/hadolint < Dockerfile || true"
                }
            }

            stage('Compile & Unit Test') {
                when { 
                    not { expression { env.LANGUAGE == 'docker-only' || env.LANGUAGE == 'nginx' } } 
                }
                steps {
                    script {
                        if (env.LANGUAGE == 'nodejs') {
                            try {
                                // Runs as root for npm install
                                sh "docker run --rm -v \${PWD}:/app -w /app node:20-alpine npm install"
                            } finally {
                                // GUARANTEED CLEANUP: Resets file ownership to the Jenkins user so cleanWs() doesn't crash
                                sh "docker run --rm -v \${PWD}:/app -w /app alpine chown -R \$(id -u):\$(id -g) ."
                            }
                        } else if (env.LANGUAGE == 'java') {
                            sh "${MVN_HOME}/bin/mvn clean package"
                        } else if (env.LANGUAGE == 'python') {
                            try {
                                // Added 'set -e' to ensure test failures instantly fail the sh block
                                sh """
                                    docker run --rm -v \${PWD}:/app -w /app python:3.12-alpine sh -c '
                                        set -e
                                        pip install flake8 pytest pytest-cov
                                        flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
                                        if [ -d "tests" ]; then 
                                            pytest --cov=app tests/ --junitxml=test-reports/results.xml
                                        else 
                                            mkdir -p test-reports
                                            echo "<testsuites></testsuites>" > test-reports/results.xml
                                        fi
                                    '
                                """
                            } finally {
                                sh "docker run --rm -v \${PWD}:/app -w /app alpine chown -R \$(id -u):\$(id -g) ."
                            }
                        }
                    }
                }
            }

            stage('Static Code Analysis') {
                when { 
                    not { expression { env.LANGUAGE == 'docker-only' } } 
                }
                steps {
                    withSonarQubeEnv('sonarqube-server') {
                        script {
                            def sonarCmd = "${SONAR_HOME}/bin/sonar-scanner -Dsonar.projectName=${SERVICE_NAME} -Dsonar.projectKey=${SERVICE_NAME}"
                            
                            if (env.LANGUAGE == 'java') {
                                sonarCmd += " -Dsonar.sources=src/main/java -Dsonar.java.binaries=target/classes"
                            } else {
                                sonarCmd += " -Dsonar.sources=."
                                if (env.LANGUAGE == 'python') {
                                    sonarCmd += " -Dsonar.language=py -Dsonar.python.version=3"
                                }
                            }
                            sh "${sonarCmd}"
                        }
                    }
                }
            }

            stage('Quality Gate') {
                when { 
                    not { expression { env.LANGUAGE == 'docker-only' } } 
                }
                steps {
                    timeout(time: 5, unit: 'MINUTES') {
                        waitForQualityGate abortPipeline: true
                    }
                }
            }

            stage('OWASP Dependency Check') {
                when { 
                    not { expression { env.LANGUAGE == 'docker-only' } } 
                }
                steps {
                    script {
                        def owaspFlags = ""
                        def failHigh = 5
                        def failNewHigh = 2
                        def failCrit = 2
                        def sBuild = true

                        if (env.LANGUAGE == 'java') {
                            owaspFlags = "--disableCentral --disableOssIndex"
                            failHigh = 100; failNewHigh = 10; failCrit = 10
                        } else if (env.LANGUAGE == 'python') {
                            owaspFlags = "--disableYarnAudit"
                            failHigh = 100; failNewHigh = 100; failCrit = 100
                            sBuild = false
                        } else if (env.LANGUAGE == 'nodejs') {
                            owaspFlags = "--disableNodeAudit --disableYarnAudit"
                        } else if (env.LANGUAGE == 'nginx') {
                            failHigh = 10
                        }
                        
                        // Perfectly maps Python's original tool-level || true execution bypass, while keeping Java/Node strict
                        def owaspCmd = "${OWASP_HOME}/bin/dependency-check.sh --project ${SERVICE_NAME} --scan . --format ALL ${owaspFlags}"
                        if (env.LANGUAGE == 'python') {
                            owaspCmd += " || true"
                        }
                        
                        sh "${owaspCmd}"
                        dependencyCheckPublisher pattern: '**/dependency-check-report.xml', failedTotalHigh: failHigh, failedNewHigh: failNewHigh, unstableTotalCritical: failCrit, stopBuild: sBuild
                    }
                }
            }

            stage('Build Docker Image') {
                steps {
                    sh "docker build -t ${FULL_IMAGE} ."
                }
            }

            stage('Trivy Image Scan') {
                steps {
                    sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v trivy-data:/root/.cache aquasec/trivy image --severity HIGH,CRITICAL ${FULL_IMAGE}"
                }
            }

            stage('Push Image to Registry') {
                when { branch 'main' }
                steps {
                    script {
                        // Note: If you are using Nexus, swap 'dockerhub-creds' with your Nexus credentials ID
                        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                            sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                            sh "docker push ${FULL_IMAGE}"
                        }
                    }
                }
            }

            stage('Update GitOps Repository (CD Handoff)') {
                when { branch 'main' }
                steps {
                    script {
                        echo "Updating GitOps repo for ${SERVICE_NAME} to tag ${IMAGE_TAG}..."
                        withCredentials([usernamePassword(credentialsId: 'github-token', passwordVariable: 'GIT_PASS', usernameVariable: 'GIT_USER')]) {
                            sh """
                                git clone https://${GIT_USER}:${GIT_PASS}@github.com/sivaram-ops/roboshop-gitops.git gitops-workspace
                                cd gitops-workspace
                                
                                # Highly targeted regex ensures no YAML syntax is broken
                                # Update the specific microservice's dev values file
                                sed -i 's/tag: "[^"]*"/tag: "${IMAGE_TAG}"/g' envs/dev/${SERVICE_NAME}/values.yaml
                                
                                git config user.name "Jenkins CI"
                                git config user.email "jenkins-ci@sivaram-ops.com"
                                # Stage the file in its new path
                                git add envs/dev/${SERVICE_NAME}/values.yaml
                                
                                if git diff-index --quiet HEAD --; then
                                    echo "No changes to commit."
                                else
                                    git commit -m "CD: Update ${SERVICE_NAME} image to ${IMAGE_TAG}"
                                    git push origin main
                                fi
                            """
                        }
                    }
                }
            }
        }
        
        post {
            always {
                script {
                    if (env.LANGUAGE == 'python') {
                        junit allowEmptyResults: true, testResults: 'test-reports/results.xml'
                    }
                }
                sh "docker rmi ${FULL_IMAGE} || true"
                cleanWs()
            }
        }
    }
}