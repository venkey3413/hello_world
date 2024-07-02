provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

resource "aws_instance" "web" {
  ami           = "ami-06c68f701d8090592"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"

  tags = {
    Name = "GitHubDeployEC2"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install docker -y
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              # Install git
              sudo yum install -y git
              # Clone the GitHub repository
              git clone ${var.github_repo_url}
              cd $(basename ${var.github_repo_url} .git)
              # Build and run the Docker container
              sudo docker build -t myapp .
              sudo docker run -d -p 3000:3000 myapp
              EOF

  key_name = "key"  # Replace with your key pair name

  vpc_security_group_ids = [aws_security_group.web_sg.id]
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
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

output "instance_ip" {
  description = "The public IP address of the web server"
  value       = aws_instance.web.public_ip
}

variable "github_repo_url" {
  description = "GitHub repository URL"
  type        = string
}
