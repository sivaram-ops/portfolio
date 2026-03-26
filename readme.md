Welcome to My Portfolio.

This repository is a Full-Stack DevOps Implementation - of an ecommerce website, 'Roboshop', built with microservices in 3-tier architecure.

Presenting a complete DevOps lifecycle from manual deployment on VMs to containerizing and orchestrating with kubernetes.

This project (Roboshop) is composed of 10 microservices in 3-tire architecture.  
Each microservice (application) is serving a distinct function and interacting with various data base services (MongoDB, MySQL, Redis, RabbitMQ).

## ⚙️ architecture: 3-tier (frontend, backend, and databases)
![3-tier architecture of roboshop](https://github.com/sivaram-ops/roboshop-3tier-microservices/blob/911ce7b9b98c183618bff020afa4105f07f74a62/assets/3-tier-microservices.png)



# About the directories in repo & their contents:
1. 1-microservices-code: The complete source code for the 10 microservices (Node, Python, Java, etc.). 10 subfolders.  
2. 2-IaC-ansible-with-roles: A playbook with Ansible roles to deploy each microservice.  
3. 3-IaC-terraform:    A terraform file to create resources in AWS.
4. 4-containerization: Highly optimized Dockerfiles and Compose file.  
5. 5-k8s-kubeadm-cluster-setup: steps to create k8s cluster using containerd or docker-engine as CRI.
6. 6-k8s-roboshop: with objects manifests, helm charts and helm base chart.
7. 7-CI-jenkins-pipelines: Jenkins Files for pipelines etc.  
8. 8-CI-jenkins-shared-library: Jenkins shared library for easy management.
9. 9-CD-k8s-argocd-controller: ArgoCD controller to deploy the applications using GitOps workflow (using git generator)
10. 'assets' directory: To store images (for markdown files)  
