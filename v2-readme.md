# Microservices Delivery Practices

Demonstraring the Deployment practices, starting from the manual method to orchestration using k8s. 


## Overview

For demonstration, I am using Stan's roboshop ecommerce website as project. Roboshop is in a 3-tier architecture with microservices including Nginx, Node, Java, Python, and databases which are mongodb, mysql, redis, and rabbitmq.

This repository can be considered as my DevOps portfolio detailing the complete journey of implementing Continuous Delivery Practices for a complex, 10-microservice, 3-Tier e-commerce application (Roboshop). 


### The project demonstrates DevOps toolchain documenting the evolution of delivery systems:

Foundational (Manual) → Automation (Ansible) → Containerization (Docker) → Orchestration (K8s) → Continuous Integration/Delivery (CI/CD)


Core Discipline         -->     Key Technologies Covered                -->     Architectural Focus
Continuous Delivery     --?     Ansible, Docker, Kubernetes, Jenkins    -->     Microservices Architecture, 3-Tier Design
Automation Engineering  -->     IaC, Configuration Management, Pipeline Design  -->     Scalability and Reliability
Infrastructure Engineering  --> Terraform, Kubeadm, AWS                 -->     Cloud Provisioning and Management


# Architectural Context: The Roboshop Platform

The solution manages the deployment of 10 distinct microservices, including building, configuration and resilience.

## ⚙️ architecture: 3-tier (frontend, backend, and databases)
<p align="center">![3-tier architecture of roboshop](https://github.com/sivaram-ops/roboshop-3tier-microservices/blob/911ce7b9b98c183618bff020afa4105f07f74a62/assets/3-tier-microservices.png)</p>


# 1. Demonstrated Delivery Practices

This section details the maturity model achieved, highlighting the strategic application of DevOps principles at each stage.


## Practice 1: Foundational Configuration Baseline (1-manual/)

Objective: Establish the reliable, documented manual configuration baseline for application deployment.

Artifacts: Detailed Markdown guides outlining dependencies and system configuration.


Practice 2: Configuration as Code (Ansible) (2-ansible/)

Objective: Implement idempotent Configuration Management across environments.

Artifacts: Dedicated Ansible playbooks and inventory demonstrating platform standardization.


Practice 3: Containerization Standards (Docker) (3-docker/)

Objective: Define and implement standards for building lightweight, optimized containers for CI/CD.

Demonstrated Skill: Use of Multi-Stage Builds for image size reduction and definition of the service network via docker-compose.


Practice 4: Container Orchestration (Kubernetes) (4-k8s-app-manifests/)

Objective: Define High Availability and scaling strategies using declarative orchestration.

Artifacts: Production-ready K8s manifests (Deployments, Services, ConfigMaps) managing the microservices lifecycle.


2. Infrastructure Engineering

The underlying cloud infrastructure (VPC, K8s cluster) is managed via a dedicated repository, showcasing best practices in separating Application Delivery from Infrastructure Engineering.

Objective: Demonstrate mastery of cloud provisioning and Kubernetes cluster bootstrapping from scratch.

Deep Dive Link: View the complete Infrastructure as Code for the environment:
Infrastructure Code Repository: Roboshop-Cloud-Infra


# Roadmap: Achieving Continuous Delivery

The immediate focus is on finalizing the CI/CD loop and infrastructure automation:

CI/CD Pipeline Integration: Implementing a Jenkinsfile in the 6-ci-cd-with-jenkins/ directory to automate the build-test-deploy sequence.

Full IaaS with Terraform: Implementing robust Terraform code to provision the entire required AWS infrastructure (VPC, EKS Cluster, etc.).


# Running the Application:

## Local Deployment with Docker: 
Run all services locally using Docker Compose.

prerequisites:
a running docker service.

# Clone the repository
git clone [https://github.com/sivaram-ops/Microservices-Delivery-Practices.git](https://github.com/sivaram-ops/Microservices-Delivery-Practices.git)
cd Microservices-Delivery-Practices/4-containerization-with-docker

# Build and Run the images to start the platform services:
docker compose up --build -d

## optional:
Feel free to use my other compose file (docker-compose-docker-hub-artifacts.yaml) to use the docker images that I built and stored in my docker hub account.
docker compose up -f docker-compose-docker-hub-artifacts.yaml -d

# Prerequisites to orchestrate on k8-s:
A running Kubernetes cluster    (check my other repo with the steps to launch k8s-cluster with docker or containerd)

link to k8s-manifests-directory: 