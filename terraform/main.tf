provider "aws" {
  region = var.region

  # Assuming a role if cross-account access is required
  assume_role {
    role_arn = var.role_arn
  }
}

# Define the ECS cluster
resource "aws_ecs_cluster" "hello_world_cluster" {
  name = "hello-world-nodejs-cluster"
}

# Define the ECS task definition
resource "aws_ecs_task_definition" "hello_world_task" {
  family                   = "hello-world-nodejs-task"
  container_definitions    = jsonencode([{
    name  = "hello-world-nodejs-container"
    image = var.docker_image
    memory = 512
    cpu = 256
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = "arn:aws:iam::${var.account_id}:role/ecsTaskExecutionRole"
}

# Define the ECS service
resource "aws_ecs_service" "hello_world_service" {
  name            = "hello-world-nodejs-service"
  cluster         = aws_ecs_cluster.hello_world_cluster.id
  task_definition = aws_ecs_task_definition.hello_world_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = var.security_group_ids
  }
}

# Define necessary IAM role and policy (if not already created)
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

output "cluster_id" {
  value = aws_ecs_cluster.hello_world_cluster.id
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.hello_world_task.arn
}

output "service_name" {
  value = aws_ecs_service.hello_world_service.name
}
