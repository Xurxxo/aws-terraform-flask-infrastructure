variable "region" {
  description = "AWS region for infrastructure deployment"
  type        = string
  default     = "eu-central-1"
}

variable "ecr_image_url" {
  description = "Full ECR image URL including registry and tag"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "app_port" {
  description = "Application port inside the container"
  type        = number
  default     = 8000
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
  default     = null
}