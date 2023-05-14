# NOTE:
# All infrastructure is created regarding to official documentation of Terraform.
# Reference link: https://registry.terraform.io/

#########################
# Network (default)
# Note: That example of network, try to create your own
#########################

# VPC
resource "aws_default_vpc" "default" {
  tags = {
    "Created by" = "AWS"
  }
}

# Subnets
resource "aws_default_subnet" "default_az1" {
  availability_zone = "${var.region}a"
  tags = {
    "Created by" = "AWS"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "${var.region}b"
  tags = {
    "Created by" = "AWS"
  }
}

resource "aws_default_subnet" "default_az3" {
  availability_zone = "${var.region}c"
  tags = {
    "Created by" = "AWS"
  }
}

#########################
# EC2 - Autoscaling
#########################

# Launch Template
resource "aws_launch_template" "demo" {
  name                   = "${var.name}-launch-template"
  image_id               = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.demo.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.demo_ecs.name
  }

  tags      = var.additional_tags
  user_data = base64encode(file("userdata.tpl"))
}

# Security Group
resource "aws_security_group" "demo" {
  name        = "${var.name}-sg-instance"
  description = "Allow inbound traffic for me"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = var.allowed_port
    to_port     = var.allowed_port
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# IAM Role Spot Fleet
resource "aws_iam_role" "demo_fleet" {
  name_prefix        = "${var.name}-spot-fleet-role"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy-for-spotfleet.json
}

resource "aws_iam_role_policy_attachment" "demo_fleet" {
  role       = aws_iam_role.demo_fleet.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}

resource "aws_spot_fleet_request" "demo_fleet" {
  iam_fleet_role      = aws_iam_role.demo_fleet.arn
  target_capacity     = 1
  allocation_strategy = "lowestPrice"

  launch_template_config {
    launch_template_specification {
      id      = aws_launch_template.demo.id
      version = aws_launch_template.demo.latest_version
    }
  }
}

# Autoscaling Spot Fleet
# Reference link: 
# https://docs.aws.amazon.com/autoscaling/application/APIReference/API_RegisterScalableTarget.html#API_RegisterScalableTarget_RequestSyntax
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "spot-fleet-request/${aws_spot_fleet_request.demo_fleet.id}"
  scalable_dimension = "ec2:spot-fleet-request:TargetCapacity"
  service_namespace  = "ec2"
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

#########################
# Cluster
#########################

# ECR
resource "aws_ecr_repository" "repository" {
  name                 = var.repo_name
  image_tag_mutability = "MUTABLE"
}

# ECS
resource "aws_ecs_cluster" "demo" {
  name = "${var.name}-cluster"
}

# IAM Role ECS Instance
resource "aws_iam_role" "demo_ecs" {
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy-for-ecs-node.json
  name               = "${var.name}-ecsInstanceRole"
}
resource "aws_iam_role_policy_attachment" "demo_ecs" {
  role       = aws_iam_role.demo_ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
resource "aws_iam_instance_profile" "demo_ecs" {
  role = aws_iam_role.demo_ecs.name
  name = "${var.name}-ecsInstanceProfile"
}

# IAM Role Task Execution
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.name}-ECSTaskExecRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy" "aws_ecs_task_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attached_to_exec_role" {
  policy_arn = data.aws_iam_policy.aws_ecs_task_execution_role.arn
  role       = aws_iam_role.ecs_task_execution.name
}

# Task definition
resource "aws_ecs_task_definition" "task_definition" {

  family                   = "${var.name}-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
    {
      name      = "${var.name}-gin-gonic"
      image     = "${aws_ecr_repository.repository.repository_url}:latest"
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.allowed_port
        }
      ]
    }
  ])
}

