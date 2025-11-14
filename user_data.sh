#!/bin/bash
set -e

exec > /var/log/user-data.log 2>&1

echo "Starting EC2 instance configuration"
echo "Timestamp: $(date)"

REGION="${region}"
ECR_IMAGE_URL="${ecr_image_url}"
APP_PORT="${app_port}"

echo "Updating system packages"
dnf update -y

echo "Installing Docker"
dnf install -y docker

echo "Starting Docker service"
systemctl enable docker
systemctl start docker

if ! systemctl is-active --quiet docker; then
    echo "ERROR: Docker service failed to start"
    exit 1
fi

echo "Docker installed successfully"
docker --version

echo "Authenticating with Amazon ECR"
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $(echo $ECR_IMAGE_URL | cut -d'/' -f1)

if [ $? -eq 0 ]; then
    echo "ECR login successful"
else
    echo "ERROR: ECR login failed"
    exit 1
fi

echo "Pulling Docker image from ECR"
docker pull $ECR_IMAGE_URL

if [ $? -eq 0 ]; then
    echo "Image pulled successfully"
else
    echo "ERROR: Failed to pull image"
    exit 1
fi

echo "Running Flask container"
docker run -d \
  --name flask-cv-app \
  --restart unless-stopped \
  -p 80:$APP_PORT \
  $ECR_IMAGE_URL

if [ $? -eq 0 ]; then
    echo "Container started successfully"
else
    echo "ERROR: Failed to start container"
    exit 1
fi

echo "Checking container status"
sleep 5
docker ps

echo "Configuration completed successfully"
echo "Application should be accessible on port 80"
echo "Final timestamp: $(date)"