# Roboshop: Full-Stack DevOps Implementation - Project


## Overview (about the respository):
This project implements a complete DevOps lifecycle for Roboshop, a complex 3-tier, 10-microservice e-commerce application. 
The objective was to transform the environment from a manual, configuration-heavy setup to a modern, automated, and containerized deployment using Infrastructure as Code (IaC) and Container Orchestration.

This repository serves as the central showcase, containing the final application code, deployment artifacts (Docker/K8s), and the architectural overview. Detailed IaC implementation (Ansible, Terraform) is located in specialized, linked repositories.


## Key Technologies Implemented: (with DevOps Practice Demonstrated)
IaaS: Terraform (AWS)                       -->     Infrastructure as Code (IaaS)
Config Mgt: Ansible (Roles/Playbooks)       -->     Configuration Management
Packaging: Docker (Multi-Stage Builds)      -->     Containerization & Optimization
Orchestration: Docker Compose, Kubernetes   -->     Container Orchestration with Kubernetes
CI/CD: Jenkins (Planned)                    -->     Continuous Integration & Delivery


## ⚙️ Architecture Diagram:
This project is (Roboshop) is composed of 10 microservices in 3-tire architecture. Each microservice (application) is serving a distinct function and interacting with various data base services (MongoDB, MySQL, Redis, RabbitMQ).

![3-tier architecture of roboshop](https://drive.google.com/file/d/1DeEeT5s3_uXya-2kOvvy7k5QHPoS-P9S/view?usp=sharing)


# 1. The Deployment Story: From Manual to IaC

This section narrates the evolution of the deployment method, demonstrating a progressive growth in DevOps maturity.


## Phase 1: Manual Deployment & Linux Fundamentals 
### directory name: (1-manual-deployment/)

Goal: Successfully deploy and configure all 10 microservices using only shell commands on separate EC2 instances.

Demonstrated Skills: Deep understanding of application dependencies, service configuration (Nginx, systemd), Linux package management, and basic networking.

Artifacts: The 1-manual-deployment/manual-steps.md file details the configuration logic for each service.


## Phase 2: Configuration Automation (Ansible)

Goal: Refactor the manual steps into idempotent Ansible playbooks and roles for reliable, repeatable, and scalable configuration management.

Demonstrated Skills: Advanced Ansible (Roles structure, handlers, templates, variables), idempotency, and environment-specific configuration.

Deep Dive Link: View the complete Ansible code base, including roles and my learning files:
👉 Ansible Code Repository: roboshop-ansible-iac


## Phase 3: Application Containerization (Docker)

Goal: Package each microservice into a lightweight Docker container for environment consistency and portability.

Demonstrated Skills: Multi-stage builds for reduced image size, optimizing Dockerfiles for caching and security, and using docker-compose for local orchestration. 
Note: Final images were uploaded to my docker hub repository. link: sivaram0101  

Artifacts: The final, optimized Dockerfiles and the multi-service docker-compose.yaml are located in the 2-docker/ directory.


## Phase 4: Container Orchestration (Kubernetes)

Goal: Deploy the containerized application to a Kubernetes cluster (e.g., Minikube, EKS, or Kubeadm).

Demonstrated Skills: Writing robust K8s manifests (Deployments, Services, ConfigMaps, Persistent Volumes) to manage service discovery, scaling, and stateful applications.

Artifacts: Kubernetes YAML manifests for the Roboshop components are in the 3-k8s-manifests/ directory.



# 2. Infrastructure as Code (IaaS)

The underlying cloud infrastructure (VPC, Security Groups, EC2 instances, EKS Cluster) for this project is managed entirely using Terraform.

Goal: Define and provision all necessary AWS resources needed to host the applications.

Demonstrated Skills: Terraform providers, state management, creating modular infrastructure components (VPC, Subnets, EC2), and managing cloud security rules.

Deep Dive Link: View the complete Terraform IaaS code base, demonstrating the provisioning of the environment:
👉 Terraform Infrastructure Repository: roboshop-terraform-infra



# ⏭️ Next Steps & Roadmap

My current focus is to complete the full CI/CD pipeline to automate the entire process from code commit to deployment.

## Continuous Delivery (CI/CD): 
To implement a Jenkins pipeline to automatically build new Docker images, push them to a registry (Docker Hub/Jfrog), and trigger the Kubernetes deployment upon merge to the main branch.

## Monitoring & Observability: 
Integrate Prometheus and Grafana for comprehensive monitoring of microservice health and performance.

## Advanced K8s: 
Implement advanced features like Ingress Controllers, Helm charts for packaged deployment, and Network Policies.


# 💻 Running the Application

## Prerequisites:
1. Docker installed.
2. A running Kubernetes cluster (for K8s deployment).


## Local Docker Deployment (Quick Start)
To deploy all 10 microservices locally using the cleaned Docker artifacts:

1. Clone this repository:
git clone https://github.com/sivaram-ops/roboshop-devops-project.git

2. Build all images and start the services:
cd roboshop-devops-project/2-docker
docker compose up --build -d

3. Check the status of the containers:
docker compose ps


The application will be accessible via your Docker host IP on port 80.

For more information, feel free to contact me.