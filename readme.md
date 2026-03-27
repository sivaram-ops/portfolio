# Roboshop: Microservices Deployment and CI/CD

This repository contains configuration files, scripts, and deployment manifests for Roboshop, a 3-tier e-commerce application consisting of 10 microservices. The project demonstrates the progression of deployment methods from configuration management to container orchestration and automated CI/CD pipelines.

## Application Architecture

The application follows a standard 3-tier architecture:
* **Frontend:** Nginx 
* **Backend Services:** Catalogue, User, Cart, Shipping, Payment 
* **Databases & Brokers:** MongoDB, MySQL, Redis, RabbitMQ 

![3-tier architecture of roboshop](https://github.com/sivaram-ops/roboshop-3tier-microservices/blob/911ce7b9b98c183618bff020afa4105f07f74a62/assets/3-tier-microservices.png)

## Repository Structure

The repository is organized into directories representing different deployment stages and practices:

* **`1-roboshop-source-code/`**: Source code of 10 microservices. 
* **`2-iac-ansible-with-roles/`**: Ansible playbooks and roles for configuring and deploying the microservices on VMs.
* **`3-iac-terraform/`**: Terraform scripts for provisioning AWS infrastructure (VPC, Subnets, EC2).
* **`4-containerization/`**: Dockerfiles for all microservices and a `docker-compose.yaml` file for local deployment.
* **`5-k8s-kubeadm-cluster-setup/`**: Documentation and commands for bootstrapping a Kubernetes cluster using Kubeadm, covering both containerd and Docker runtimes.
* **`6-k8s-roboshop/`**: Kubernetes deployment resources, including raw YAML manifests, standard Helm charts, and a reusable Helm base chart.
* **`7-ci-jenkins-pipelines/`**: Declarative Jenkinsfiles for continuous integration.
* **`8-ci-jenkins-shared-library/`**: A Groovy-based Jenkins shared library to manage reusable pipeline code across the applications.
* **`9-cd-k8s-argocd-controller/`**: ArgoCD ApplicationSet configurations for GitOps-based continuous delivery to the Kubernetes cluster.

## Local Deployment (Docker Compose)

You can run the entire application stack locally using Docker Compose. Ensure Docker and Docker Compose are installed on your machine.

1. **Clone the repository and navigate to the containerization directory**:
   ```bash
   git clone [https://github.com/sivaram-ops/Microservices-Delivery-Practices.git](https://github.com/sivaram-ops/Microservices-Delivery-Practices.git)
   cd Microservices-Delivery-Practices/4-containerization

1. **Clone the repository and navigate to the containerization directory**:
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