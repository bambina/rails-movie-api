# Terraform configuration
terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# AWS Provider configuration
provider "aws" {
  region = var.region

  # Default tags applied to all resources
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "al2023" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# EC2 Instance
resource "aws_instance" "app" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.ec2_instance_type
  subnet_id                   = values(aws_subnet.public)[0].id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true # Enable public IP for SSH access from my IP
  key_name                    = var.ec2_key_name

  # User data script executed at instance launch
  user_data = file("${path.module}/user_data.sh")

  # Root EBS volume configuration
  root_block_device {
    volume_type = var.ec2_root_volume_type
    volume_size = var.ec2_root_volume_gb
  }

  tags = { Name = "app-ec2" }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "private" {
  name       = "${var.project_name}-${var.environment}-rds-subnet-group"
  subnet_ids = values(aws_subnet.private)[*].id
  tags       = { Name = "${var.project_name}-${var.environment}-rds-subnet-group" }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "rds_postgres" {
  identifier     = "rds-postgres"
  engine         = "postgres"
  engine_version = "16.9"
  instance_class = "db.t4g.micro"

  # Database configuration
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Storage configuration
  allocated_storage = var.db_allocated_gb
  storage_type      = var.db_storage_type
  storage_encrypted = true

  # Network and security configuration
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.private.name

  # Snapshot configuration
  skip_final_snapshot     = true
  backup_retention_period = 0

  tags = { Name = "rds-postgres" }
}

# Outputs
output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app.public_ip
}
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.rds_postgres.address
}
output "application_url" {
  description = "URL to access the application"
  value       = "https://${var.app_domain}"
}
