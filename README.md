# What is it? 

It's a simple web application based on [Gin](https://github.com/gin-gonic/gin).
This repository provides Terraform and GitHub Actions codes as example of deploying infrastructure and CI/CD

## Key features

1. Push to the `main` branch of the repository triggering building the server’s Docker image and uploading to AWS ECR. 
2. The image is being deployed as a service to the AWS ECR cluster after uploading itself to AWS ECR. 
3. The ECS cluster is running on managed EC2 spot fleet instances with autoscaling.
4. ECS deployment is updating in a rolling update with zero downtime during deployments. 
5. When a new deployment fails, the old version should remain operational to avoid service disruption.


## Usage

Deployment infrastructure is possible via [Terraform](https://www.terraform.io/)

```
terraform plan
terraform apply --auto-approve
```

## Infrastructure

All infrastructure is managed by [Terraform](https://www.terraform.io/) except [OpenVPN](https://openvpn.net/) server and IAM Role for GitHub Actions.

## Docker

Web application build on Docker resources in Dockerfile. Dockerfile divided by two main steps as Build and Run. First, we build application to Go Build and next we run this build on Alpine. It makes Docker image less weight.


## OpenVPN

Documentation of deployment OpenVPN server on AWS is located [here](https://github.com/sbodnia/demo-webapp-gin/tree/main/openvpn)

## Authors

Option managed by [Serhii Bodnia](https://github.com/sbodnia).