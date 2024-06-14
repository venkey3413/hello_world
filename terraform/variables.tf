variable "region" {
  description = "The AWS region to deploy to"
  default     = "us-east-1"
}

variable "role_arn" {
  description = "The role to assume"
}

variable "docker_image" {
  description = "The Docker image for the ECS task"
}

variable "account_id" {
  description = "958955696306"
}

variable "subnet_ids" {
  description = "subnet-0c2db15cd6f86cbc4"
  type        = list(string)
}

variable "security_group_ids" {
  description = "sg-096b3e9c824a7ba70"
  type        = list(string)
}
