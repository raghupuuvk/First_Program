terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.50.0"
    }
  }
}

provider "aws" {
  # Configuration options
 region = "us-east-1"
}

resource "aws_vpc" "vpc1_call" {
  cidr_block       = "20.20.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC1"
  }
}

resource "aws_subnet" "PublicSubnet_call" {
  vpc_id     = aws_vpc.vpc1_call.id
  cidr_block = "10.10.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "V1PublicSubnet"
  }
}

resource "aws_subnet" "PrivateSubnet_call" {
  vpc_id     = aws_vpc.vpc1_call.id
  cidr_block = "10.10.2.0/24"

  tags = {
    Name = "V1PrivateSubnet"
  }
}

resource "aws_internet_gateway" "IGW1_call" {
  vpc_id = aws_vpc.vpc1_call.id

  tags = {
    Name = "IGW1"
  }
}

resource "aws_default_route_table" "MRT1_call" {
  default_route_table_id = aws_vpc.vpc1_call.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW1_call.id
  }

  tags = {
    Name = "MRT1"
  }
}


resource "aws_route_table" "CRT1_call" {
  vpc_id = aws_vpc.vpc1_call.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NGW1_call.id
  }

  tags = {
    Name = "CRT1"
  }
}

resource "aws_route_table_association" "mrt1_call_association" {
  subnet_id      = aws_subnet.PublicSubnet_call.id
  route_table_id = aws_default_route_table.MRT1_call.id
}

resource "aws_route_table_association" "crt1_call_association" {
  subnet_id      = aws_subnet.PrivateSubnet_call.id
  route_table_id = aws_route_table.CRT1_call.id
}

resource "aws_eip" "eip_call" {
 network_border_group = "us-east-1"
}

resource "aws_nat_gateway" "NGW1_call" {
  connectivity_type = "public"
  allocation_id = aws_eip.eip_call.id
  subnet_id         = aws_subnet.PublicSubnet_call.id

  tags = {
    Name = "NGW1"
  }
}


