terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }

    required_version = ">= 1.2.0"
}

provider "aws" {
    region = var.region
    profile = "brunofreitas-UbuntuHome"
}

# VPC
resource "aws_vpc" "lab-aws-2024-tf" {
  cidr_block = "10.1.1.0/24"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    laboratorio-tf = "2024"
    Name = "lab-aws-2024-tf"
  }
}

#route table
resource "aws_default_route_table" "lab-aws-2024-tf-subnet-public1-AZ1-route-table" {
  default_route_table_id = aws_vpc.lab-aws-2024-tf.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab-aws-2024-tf-igw1.id
  }

  tags = {
    laboratorio-tf = "2024"
    Name = "lab-aws-2024-tf-subnet-public1-AZ1-route-table"
  }
}

#internet gateway
resource "aws_internet_gateway" "lab-aws-2024-tf-igw1" {
  vpc_id = aws_vpc.lab-aws-2024-tf.id
  tags = {
    laboratorio-tf = "2024"
  }
}

# Subnets
resource "aws_subnet" "lab-aws-2024-tf-subnet-public1-AZ1" {
  vpc_id              	= aws_vpc.lab-aws-2024-tf.id
  cidr_block          	= "10.1.1.0/25"
  availability_zone   	= var.AZ_location
  map_public_ip_on_launch = true
  tags = {
    laboratorio-tf = "2024"
  }
}

# Subnets
resource "aws_subnet" "lab-aws-2024-tf-subnet-private1-AZ1" {
  vpc_id              	= aws_vpc.lab-aws-2024-tf.id
  cidr_block          	= "10.1.1.128/25"
  availability_zone   	= var.AZ_location
  map_public_ip_on_launch = false
  tags = {
    laboratorio-tf = "2024"
  }
}

# Network ACL
resource "aws_default_network_acl" "lab-aws-2024-tf-nacl-default" {
  default_network_acl_id = aws_vpc.lab-aws-2024-tf.default_network_acl_id

  ingress {
	rule_no   = 100
	protocol  	= "-1"
	action   = "allow"
	cidr_block	= "0.0.0.0/0"
	from_port 	= 0
	to_port   	= 0
  }

  egress {
	rule_no   = 100
	protocol  	= "-1"
	action   = "allow"
	cidr_block	= "0.0.0.0/0"
	from_port 	= 0
	to_port   	= 0
  }

  tags = {
    laboratorio-tf = "2024"
  }
}

# Security Group
resource "aws_security_group" "lab-aws-2024-tf-sg-default" {
  name    	= "Lab2024-TF Default"
  description = "Allow SSH inbound and all outbound traffic"
  vpc_id  	= aws_vpc.lab-aws-2024-tf.id

  ingress {
	from_port   = 22
	to_port 	= 22
	protocol	= "tcp"
	cidr_blocks = ["0.0.0.0/0"] #meu ip publico "187.73.197.21/32"
  }

  egress {
	from_port   = 0
	to_port 	= 0
	protocol	= "-1"
	cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    laboratorio-tf = "2024"
  }
}


resource "aws_instance" "lab-test-1" {
    ami= "ami-0c20d88b0021158c6"
    instance_type           = "t2.micro"
    subnet_id               = aws_subnet.lab-aws-2024-tf-subnet-public1-AZ1.id
    vpc_security_group_ids  = [aws_security_group.lab-aws-2024-tf-sg-default.id] 
    key_name                = var.keypair01
    tags                    = {
                            laboratorio-tf = "2024"
                            Name = "lab-aws-2024-tf-test-1"
                            }   
    iam_instance_profile = "role-acesso-ssm"
    
}

#resource "aws_instance" "lab-test-2" {
#    ami= "ami-0c20d88b0021158c6"
#    instance_type           = "t2.micro"
#    subnet_id               = aws_subnet.lab-aws-2024-tf-subnet-private1-AZ1.id
#    vpc_security_group_ids  = [aws_security_group.lab-aws-2024-tf-sg-default.id] 
#    key_name                = "laboratorio-aws-2024-keys" 
#    tags                    = {
#                            laboratorio-tf = "2024"
#                            Name = "lab-aws-2024-tf-test-2"
#                            }   
#}