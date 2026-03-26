# Roboshop: Microservices Deployment and CI/CD

[cite_start]This repository contains configuration files, scripts, and deployment manifests for Roboshop, a 3-tier e-commerce application consisting of 10 microservices[cite: 28, 35]. [cite_start]The project demonstrates the progression of deployment methods from configuration management to container orchestration and automated CI/CD pipelines[cite: 31].

## Application Architecture

[cite_start]The application follows a standard 3-tier architecture[cite: 35]:
* [cite_start]**Frontend:** Nginx [cite: 35]
* [cite_start]**Backend Services:** Catalogue, User, Cart, Shipping, Payment [cite: 36]
* [cite_start]**Databases & Brokers:** MongoDB, MySQL, Redis, RabbitMQ [cite: 36]

![3-tier architecture of roboshop](https://github.com/sivaram-ops/roboshop-3tier-microservices/blob/911ce7b9b98c183618bff020afa4105f07f74a62/assets/3-tier-microservices.png)

## Repository Structure

The repository is organized into directories representing different deployment stages and practices:

* [cite_start]**`2-iac-ansible-with-roles/`**: Ansible playbooks and roles for configuring and deploying the microservices on VMs[cite: 38].
* [cite_start]**`3-iac-terraform/`**: Terraform scripts for provisioning AWS infrastructure (VPC, Subnets, EC2)[cite: 39].
* [cite_start]**`4-containerization/`**: Dockerfiles for all microservices and a `docker-compose.yaml` file for local deployment[cite: 40].
* [cite_start]**`5-k8s-kubeadm-cluster-setup/`**: Documentation and commands for bootstrapping a Kubernetes cluster using Kubeadm, covering both containerd and Docker runtimes[cite: 41].
* [cite_start]**`6-k8s-roboshop/`**: Kubernetes deployment resources, including raw YAML manifests, standard Helm charts, and a reusable Helm base chart[cite: 42].
* [cite_start]**`7-ci-jenkins-pipelines/`**: Declarative Jenkinsfiles for continuous integration[cite: 43].
* [cite_start]**`8-ci-jenkins-shared-library/`**: A Groovy-based Jenkins shared library to manage reusable pipeline code across the applications[cite: 44].
* [cite_start]**`9-cd-k8s-argocd-controller/`**: ArgoCD ApplicationSet configurations for GitOps-based continuous delivery to the Kubernetes cluster[cite: 45].

## Local Deployment (Docker Compose)

[cite_start]You can run the entire application stack locally using Docker Compose[cite: 46]. [cite_start]Ensure Docker and Docker Compose are installed on your machine[cite: 46].

1. [cite_start]**Clone the repository and navigate to the containerization directory**:
   ```bash
   git clone https://github.com/sivaram-ops/Microservices-Delivery-Practices.git
   cd Microservices-Delivery-Practices/4-containerization
   ```

2. Build the images and start the services:
    ```Bash
    docker compose up --build -d
    ```

3. Verify the containers are running:
    ```Bash
    docker compose ps
    ```
The application frontend will be accessible via your localhost IP on port 80.