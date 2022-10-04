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

# adopt the default role created by AWS to run the task under
data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

# define a task for the frontend webserver
resource "aws_ecs_task_definition" "taskjuggler_frontend_webserver" {
  family                   = "taskjuggler_frontend_webserver"
  task_role_arn            = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  execution_role_arn       = "${data.aws_iam_role.ecs_task_execution_role.arn}"
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

# create a security group
#
# this is used to allow network traffic to reach our containers
resource "aws_security_group" "taskjuggler_security_group" {
  name = "taskjuggler_security_group"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# adopt the default AWS VPC as a resource in terraform. see:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "default VPC"
  }
}

# create a subnet for taskjuggler
resource "aws_subnet" "taskjuggler_subnet" {
  cidr_block = "172.31.16.0/20"
  vpc_id = aws_default_vpc.default_vpc.id
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
    subnets          = [aws_subnet.taskjuggler_subnet.id]
    security_groups  = [aws_security_group.taskjuggler_security_group.id]
    assign_public_ip = true
  }
}
