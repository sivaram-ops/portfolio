# Provider
provider "aws" {
  region = "us-east-1"
}
# note:
# 1. for security reasons, i removed the provider's access and secret key, and set'em as env vars on my machine.
# 2. hard coded most of the values here for easy reference. I will add a new tf file with env vars calling from env file. 

# VPC
resource "aws_vpc" "roboshop-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "roboshop-vpc-btf"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "roboshop-gw" {
  vpc_id = aws_vpc.roboshop-vpc.id
  tags = {
    Name = "roboshop-gw-btf"
  }
}

# Subnet in us-east-1a
resource "aws_subnet" "roboshop-subnet" {
  vpc_id                  = aws_vpc.roboshop-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "roboshop-subnet-btf-us-east-1a"
  }
}

# Route Table
resource "aws_route_table" "roboshop-route-table" {
  vpc_id = aws_vpc.roboshop-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.roboshop-gw.id
  }
  
  tags = {
    Name = "roboshop-route-table-btf"
  }
}

# Route Table Association with Subnet
resource "aws_route_table_association" "routes-for-roboshop" {
  subnet_id      = aws_subnet.roboshop-subnet.id
  route_table_id = aws_route_table.roboshop-route-table.id
}

# Security Group
resource "aws_security_group" "roboshop-sg" {
  name        = "roboshop-sg-btf"
  description = "Allow Port 22 (SSH) and Port 80 (HTTP)"
  vpc_id      = aws_vpc.roboshop-vpc.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "roboshop-sg-btf"
  }
}

# EC2 Instance
resource "aws_instance" "roboshop-instance" {
  ami                         = "ami-0fa3fe0fa7920f68e"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.roboshop-subnet.id
  vpc_security_group_ids      = [aws_security_group.roboshop-sg.id]
  key_name                    = "aws-kp" # Ensure this key pair exists in us-east-1

  # To install Nginx.
  user_data = <<-EOF
    #!/bin/bash
    sudo dnf update -y
    sudo dnf install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
    sudo bash -c 'echo "<h1>Hello from Roboshop Instance!</h1>" > /usr/share/nginx/html/index.html'
  EOF

  tags = {
    Name = "roboshop-instance-btf"
  }
  
  depends_on = [
    aws_internet_gateway.roboshop-gw,
  ]
}

# To print the EC2 Instance Public IP in outputs:
output "roboshop_public_ip" {
  value = aws_instance.roboshop-instance.public_ip
}