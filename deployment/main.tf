# configures terraform to use the AWS provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# configures the AWS provider
provider "aws" {
  region = "us-east-1"
}

# define an ECS cluster for taskjuggler
resource "aws_ecs_cluster" "taskjuggler_cluster" {
  name = "taskjuggler_cluster"
}

# define a task for the frontend webserver
resource "aws_ecs_task_definition" "taskjuggler_frontend_webserver" {
  family                   = "taskjuggler_frontend_webserver"
  task_role_arn            = "arn:aws:iam::186932938567:role/ecsTaskExecutionRole"
  execution_role_arn       = "arn:aws:iam::186932938567:role/ecsTaskExecutionRole"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      name      = "frontend_webserver"
      image     = "186932938567.dkr.ecr.us-east-1.amazonaws.com/frontend_webserver"
      essential = true
      command   = ["nginx", "-g", "daemon off;"]
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

# define a service, running 5 instances of the frontend webserver
resource "aws_ecs_service" "taskjuggler_frontend_webserver_service" {
  name                   = "taskjuggler_frontend_webserver_service"
  enable_execute_command = true
  launch_type            = "FARGATE"
  cluster                = aws_ecs_cluster.taskjuggler_cluster.id
  task_definition        = aws_ecs_task_definition.taskjuggler_frontend_webserver.id
  desired_count          = 5
  network_configuration {
    subnets          = ["subnet-0b8f437d046a9d818"]
    security_groups  = ["sg-057af67719d0de21b"]
    assign_public_ip = true
  }
}
