variable "region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "eu-west-2"
}

variable "name" {
  description = "Specific name for projects resources"
  type        = string
}

variable "repo_name" {
  description = "Specific name for ECR"
  type        = string
}

variable "additional_tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}

variable "ami" {
  description = "An image id that will be deployed on ECS"
  type        = string
}

variable "instance_type" {
  description = "Specify instance type"
  type        = string
}

variable "allowed_ip" {
  description = "Allowed specific IP get the output"
  type        = string
  default     = "0.0.0.0"
}

variable "allowed_port" {
  description = "Exposing host port"
  type        = number
  default     = 8080
}

variable "container_port" {
  description = "Exposing container port"
  type        = number
  default     = 8080
}