# Roboshop: Microservices Delivery Practices & DevOps Portfolio

## Overview

This repository serves as my complete DevOps portfolio, detailing the journey of implementing Continuous Delivery Practices for a complex, 10-microservice, 3-tier e-commerce application known as **Roboshop**. 

The objective of this project is to document the transformation of a complex environment from a manual, configuration-heavy setup to a modern, automated, and containerized deployment using Infrastructure as Code (IaC) and Container Orchestration. The application itself utilizes a variety of technologies including Nginx, Node.js, Java, Python, and several databases (MongoDB, MySQL, Redis, RabbitMQ).

## Evolution of Delivery Systems

This project demonstrates a complete DevOps toolchain, documenting the evolution of software delivery practices:

**Foundational (Manual) → Automation (Ansible) → Containerization (Docker) → Orchestration (K8s) → Continuous Integration/Delivery (CI/CD)**

| Core Discipline | Key Technologies Covered | Architectural Focus |
| :--- | :--- | :--- |
| **Continuous Delivery** | Docker, Kubernetes, Jenkins, ArgoCD | Microservices Architecture, 3-Tier Design |
| **Automation Engineering** | Ansible, Configuration Management | Scalability and Reliability |
| **Infrastructure Engineering**| Terraform, Kubeadm, AWS | Cloud Provisioning and Management |

## ⚙️ Architecture: 3-Tier (Frontend, Backend, Databases)

The Roboshop platform is composed of 10 distinct microservices serving distinct functions:
* **Frontend**: Nginx-based UI.
* **Backend Services**: Catalogue, User, Cart, Shipping, Payment.
* **Databases/Message Brokers**: MongoDB, Redis, MySQL, RabbitMQ.

![3-tier architecture of roboshop](https://github.com/sivaram-ops/roboshop-3tier-microservices/blob/911ce7b9b98c183618bff020afa4105f07f74a62/assets/3-tier-microservices.png)

## Repository Structure

The repository is logically divided into numbered directories following the DevOps lifecycle:

* **`1-roboshop-source-code/`**: Contains the complete application source code for all 10 microservices (Node.js, Python, Java, etc.).
* **`2-iac-ansible-with-roles/`**: Ansible playbooks and roles designed to automate the configuration and deployment of each microservice onto VMs.
* **`3-iac-terraform/`**: Terraform scripts to provision cloud infrastructure (AWS EC2, VPC, etc.).
* **`4-containerization/`**: Highly optimized, multi-stage Dockerfiles for all microservices, along with a `docker-compose.yaml` file for local orchestration.
* **`5-k8s-kubeadm-cluster-setup/`**: Documentation and steps to bootstrap a Kubernetes cluster using Kubeadm (with containerd/docker runtimes).
* **`6-k8s-roboshop/`**: Kubernetes deployment files including raw manifests, Helm charts, and a Helm base chart.
* **`7-ci-jenkins-pipelines/`**: Declarative Jenkinsfiles for implementing Continuous Integration for the microservices.
* **`8-ci-jenkins-shared-library/`**: Groovy-based Jenkins shared library for managing reusable pipeline code.
* **`9-cd-k8s-argocd-controller/`**: ArgoCD ApplicationSet and GitOps workflow configurations for Continuous Delivery.

## Running the Application (Local Deployment)

To quickly deploy all 10 microservices locally using Docker Compose:

**Prerequisites:** Docker and Docker Compose installed.

1. **Clone this repository:**
   ```bash
   git clone https://github.com/sivaram-ops/Microservices-Delivery-Practices.git
   cd Microservices-Delivery-Practices/4-containerization
   ```

2. **Build images and start the services:**
    ```bash
    docker compose up --build -d
    ```

3. **Check the status of the containers:**

    ```
    Bash
    docker compose ps
    ```

The application will be accessible via your Docker host IP on port 80.


### Next Steps & Roadmap:

My current focus is on expanding the repository and finalizing the full CI/CD loop and infrastructure automation:

- Continuous Delivery (CI/CD): Finalizing the Jenkins pipelines to automate the build-test-deploy sequence, pushing to a Private registry, and syncing with ArgoCD.

- Full IaaS with Terraform: Implementing robust Terraform code to provision the entire required AWS infrastructure (VPC, EKS Cluster, etc.).

- Monitoring & Observability: Integrating Prometheus and Grafana for comprehensive monitoring of microservice health, logs, and performance.

- Advanced K8s Features: Expanding the Kubernetes setup with advanced Ingress Controllers and stricter Network Policies.