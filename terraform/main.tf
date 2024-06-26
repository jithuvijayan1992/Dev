provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "sample" {
  name = "sample-cluster"
}

resource "aws_ecs_task_definition" "task-01" {
  family                = "task"
  container_definitions = <<DEFINITION
[
  {
    "name": "nginx",
    "image": "nginx",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "ecs-service" {
  name            = "sample-service"
  cluster         = aws_ecs_cluster.sample.id
  task_definition = aws_ecs_task_definition.task-01.arn
  desired_count   = 1
  launch_type     = "EC2"
  
  load_balancer {
    target_group_arn = aws_lb_target_group.sample.arn
    container_name   = "nginx"
    container_port   = 80
  }
}

resource "aws_lb" "sample" {
  name               = "test-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test-sg.id]
  subnets            = [aws_subnet.test-sub1.id, aws_subnet.test-sub2.id]
}

resource "aws_lb_target_group" "sample" {
  name     = "test-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.test-vpc.id
}

resource "aws_security_group" "test-sg" {
  name        = "test-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.test-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "test-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "test-sub1" {
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "test-sub2" {
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}