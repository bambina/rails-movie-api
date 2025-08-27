# Network Configuration (VPC and Subnet data sources)

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.project_name}-${var.environment}-vpc" }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-${var.environment}-igw" }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs           = slice(data.aws_availability_zones.available.names, 0, 3)
  public_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  public_map    = zipmap(local.azs, local.public_cidrs)
  private_map   = zipmap(local.azs, local.private_cidrs)
}


# Public Subnets (for ALB + EC2)
resource "aws_subnet" "public" {
  for_each                = local.public_map
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value # CIDR
  availability_zone       = each.key   # AZ
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project_name}-${var.environment}-public-${each.key}" }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}

# Public RT association
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private Subnet (for RDS)
resource "aws_subnet" "private" {
  for_each          = local.private_map
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value # CIDR
  availability_zone = each.key   # AZ
  tags              = { Name = "${var.project_name}-${var.environment}-private-${each.key}" }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-${var.environment}-private-rt" }
}

# Private RT association
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
