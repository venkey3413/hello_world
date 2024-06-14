provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "my-ecs-cluster"
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "my-ecs-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "my-node-app"
    image     = var.docker_image
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
  }])
}

resource "aws_ecs_service" "ecs_service" {
  name            = "my-ecs-service"
  cluster         = arn:aws:ecs:us-east-1:958955696306:cluster/my-ecs-cluster
  task_definition = arn:aws:ecs:us-east-1:958955696306:cluster/my-ecs-clusteraws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-0c2db15cd6f86cbc4"]  # Replace with your subnet ID
    security_groups = ["sg-096b3e9c824a7ba70"]      # Replace with your security group ID
    assign_public_ip = true
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  managed_policy_arns = [
    "arn:arn:aws:ecs:us-east-1:958955696306:cluster/my-ecs-cluster",
  ]
}

variable "docker_image" {
  description = "Docker image name"
  type        = string
}
