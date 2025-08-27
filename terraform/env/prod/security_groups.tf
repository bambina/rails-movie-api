# Security Groups Configuration

# ALB Security Group
resource "aws_security_group" "alb_tf_sg" {
  name        = "alb-tf-sg"
  description = "Allow HTTP/HTTPS from internet"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "alb-tf-sg"
  }
}
# Internet -> ALB (HTTP:80)
resource "aws_security_group_rule" "alb_http" {
  type              = "ingress"
  security_group_id = aws_security_group.alb_tf_sg.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
# Internet -> ALB (HTTPS:443)
resource "aws_security_group_rule" "alb_https" {
  type              = "ingress"
  security_group_id = aws_security_group.alb_tf_sg.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
# ALB -> EC2 (HTTP:80)
resource "aws_security_group_rule" "alb_to_ec2_80" {
  type                     = "egress"
  security_group_id        = aws_security_group.alb_tf_sg.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_sg.id
}

# EC2 Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow SSH from my IP and HTTP from ALB only"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "ec2-sg"
  }
}
# ALB -> EC2 (HTTP:80)
resource "aws_security_group_rule" "ec2_from_alb_80" {
  type                     = "ingress"
  security_group_id        = aws_security_group.ec2_sg.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_tf_sg.id
}
# My IP -> EC2 (SSH:22)
resource "aws_security_group_rule" "ec2_ssh_from_me" {
  type              = "ingress"
  security_group_id = aws_security_group.ec2_sg.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip_cidr]
}
# EC2 -> Internet
resource "aws_security_group_rule" "ec2_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.ec2_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# RDS Security Group
resource "aws_security_group" "db_sg" {
  name        = "rds-sg"
  description = "Allow Postgres from EC2 SG only"
  vpc_id      = aws_vpc.main.id

  # EC2 -> RDS (PostgreSQL:5432)
  ingress {
    description     = "Postgres from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress = []

  tags = { Name = "rds-sg" }
}
