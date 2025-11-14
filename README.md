# Flask CV Infrastructure

Terraform infrastructure for deploying a Dockerized Flask application on AWS.

## Architecture

- VPC with public subnet
- EC2 instance running Docker
- Amazon ECR for container registry
- Automated deployment with user data script

## Requirements

- Terraform >= 1.0
- AWS CLI configured
- Docker image pushed to ECR

## Usage

terraform init
terraform plan
terraform apply


## Configuration

Copy terraform.tfvars.example to terraform.tfvars and fill in your values.

## Outputs

- web_public_ip - Public IP of EC2 instance
- application_url - URL to access the application
