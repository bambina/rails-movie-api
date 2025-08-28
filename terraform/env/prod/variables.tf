# Variables

# Project Configuration
variable "project_name" {
  type    = string
  default = "rails-movie-api"
}
variable "environment" {
  type    = string
  default = "prod"
}
variable "rails_master_key" {
  type      = string
  sensitive = true
}

# AWS Configuration
variable "region" { default = "ap-northeast-1" }
variable "hosted_zone_id" { type = string }
variable "app_domain" { type = string }

# EC2 Configuration
variable "ec2_instance_type" { default = "t3.small" }
variable "ec2_key_name" { type = string }
variable "my_ip_cidr" { type = string }

# EBS Volume Configuration
variable "ec2_root_volume_gb" { default = 50 }
variable "ec2_root_volume_type" { default = "gp3" }

# RDS PostgreSQL Configuration
variable "db_name" { default = "app" }
variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "db_storage_type" {
  type    = string
  default = "gp3"
}
variable "db_allocated_gb" { default = 20 }
