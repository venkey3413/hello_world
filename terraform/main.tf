provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "example" {
  name = "example-cluster"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name        = "example-task-execution-role"
  description = "Execution role for ECS task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "example" {
  family                = "example-task-definition"
  requires_compatibilities = ["EC2"]
  network_mode          = "awsvpc"
  cpu                   = 1024
  memory                = 512
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name         = "example-container"
      image        = "venkey3413/hello_world:latest"
      cpu          = 10
      essential    = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_security_group" "ecs_service_sg" {
  name        = "example-sg"
  description = "Security group for ECS service"
  vpc_id      = "vpc-03a619c880116314a"

  ingress {
    from_port   = 8080
    to_port     = 8080
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

resource "aws_ecs_service" "example" {
  name            = "example-service"
  cluster         = aws_ecs_cluster.example.name
  task_definition = aws_ecs_task_definition.example.family
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets         = ["subnet-0c2db15cd6f86cbc4"]
    security_groups = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = true
  }
}
