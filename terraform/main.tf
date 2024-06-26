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
  execution_role_arn       = aws_iam_role.my_ecs_task_execution_role.arn  # Reference to IAM role ARN

  container_definitions = jsonencode([{
    name      = "my-node-app"
    image     = var.docker_image
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
      protocol      = "tcp"
    }]
  }])
}

resource "aws_ecs_service" "ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-0c2db15cd6f86cbc4"]  # Replace with your actual subnet ID
    security_groups = ["sg-096b3e9c824a7ba70"]       # Replace with your actual security group ID
    assign_public_ip = true
  }
}

resource "aws_iam_role" "my_ecs_task_execution_role" {
  name = "myEcsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]
}

resource "aws_iam_role_policy_attachment" "my_ecs_task_execution_role_policy" {
  role       = aws_iam_role.my_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

variable "docker_image" {
  description = "Docker image name"
  type        = string
}
