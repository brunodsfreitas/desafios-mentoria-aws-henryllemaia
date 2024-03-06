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
resource "aws_vpc" "lab-aws-redes-A-tf" {
  cidr_block = var.CIDR_blocks_A
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    environment = var.environment
    Name = "lab-aws-redes-A-tf"
  }
}

#route table 1
resource "aws_default_route_table" "lab-aws-redes-A-tf-subnet1-AZ1-public-route-table" {
  default_route_table_id = aws_vpc.lab-aws-redes-A-tf.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab-aws-redes-A-tf-igw1.id
  }

  tags = {
    environment = var.environment
    Name = "lab-aws-redes-A-tf-subnet1-AZ1-public-route-table"
  }
}


#internet gateway 1
resource "aws_internet_gateway" "lab-aws-redes-A-tf-igw1" {
  vpc_id = aws_vpc.lab-aws-redes-A-tf.id
  tags = {
    environment = var.environment
  }
}

# Subnets
resource "aws_subnet" "lab-aws-redes-A-tf-subnet1-AZ1-public" {
  vpc_id              	= aws_vpc.lab-aws-redes-A-tf.id
  cidr_block          	= var.CIDR_blocks_A_sub1
  availability_zone   	= "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    environment = var.environment
  }
}

# Subnets
resource "aws_subnet" "lab-aws-redes-A-tf-subnet2-AZ1-private" {
  vpc_id              	= aws_vpc.lab-aws-redes-A-tf.id
  cidr_block          	= var.CIDR_blocks_A_sub2
  availability_zone   	= "${var.region}a"
  map_public_ip_on_launch = false
  tags = {
    environment = var.environment
  }
}

# Subnets
resource "aws_subnet" "lab-aws-redes-A-tf-subnet1-AZ2-public" {
  vpc_id              	= aws_vpc.lab-aws-redes-A-tf.id
  cidr_block          	= var.CIDR_blocks_B_sub1
  availability_zone   	= "${var.region}b"
  map_public_ip_on_launch = true
  tags = {
    environment = var.environment
  }
}

# Subnets
resource "aws_subnet" "lab-aws-redes-A-tf-subnet2-AZ2-private" {
  vpc_id              	= aws_vpc.lab-aws-redes-A-tf.id
  cidr_block          	= var.CIDR_blocks_B_sub2
  availability_zone   	= "${var.region}b"
  map_public_ip_on_launch = false
  tags = {
    environment = var.environment
  }
}

# Network ACL
resource "aws_default_network_acl" "lab-aws-redes-A-tf-nacl-default" {
  default_network_acl_id = aws_vpc.lab-aws-redes-A-tf.default_network_acl_id

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
    environment = var.environment
  }
}

#Internet Gateway
resource "aws_internet_gateway" "lab-aws-redes-A-tf-IGW" {
  vpc_id = aws_vpc.lab-aws-redes-A-tf.id

  tags = {
    environment = var.environment
    Name = "lab-aws-redes-A-tf-IGW"
  }
}

#ENI interface
resource "aws_network_interface" "lab-aws-redes-A-tf-ENI-1" {
  subnet_id       = aws_subnet.lab-aws-redes-A-tf-subnet2-AZ1-private.id
  security_groups = [aws_security_group.lab-aws-redes-A-tf-sg-default.id]

  tags = {
    environment = var.environment
    Name = "lab-aws-redes-A-tf-ENI-1"
  }
}

#NAT Gateway
resource "aws_nat_gateway" "lab-aws-redes-A-tf-NGW" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.lab-aws-redes-A-tf-subnet2-AZ1-private.id
}

######################################################################
######################################################################
######################################################################


# VPC2
resource "aws_vpc" "lab-aws-redes-B-tf" {
  cidr_block = var.CIDR2_blocks_A
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    environment = var.environment
    Name = "lab-aws-redes-B-tf"
  }
}

#route table 1
resource "aws_default_route_table" "lab-aws-redes-B-tf-subnet1-AZ1-public-route-table" {
  default_route_table_id = aws_vpc.lab-aws-redes-B-tf.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab-aws-redes-B-tf-igw1.id
  }

  tags = {
    environment = var.environment
    Name = "lab-aws-redes-B-tf-subnet1-AZ1-public-route-table"
  }
}


#internet gateway 1
resource "aws_internet_gateway" "lab-aws-redes-B-tf-igw1" {
  vpc_id = aws_vpc.lab-aws-redes-B-tf.id
  tags = {
    environment = var.environment
  }
}

# Subnets
resource "aws_subnet" "lab-aws-redes-B-tf-subnet1-AZ1-public" {
  vpc_id              	= aws_vpc.lab-aws-redes-B-tf.id
  cidr_block          	= var.CIDR2_blocks_A_sub1
  availability_zone   	= "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    environment = var.environment
  }
}

# Subnets
resource "aws_subnet" "lab-aws-redes-B-tf-subnet2-AZ1-private" {
  vpc_id              	= aws_vpc.lab-aws-redes-B-tf.id
  cidr_block          	= var.CIDR2_blocks_A_sub2
  availability_zone   	= "${var.region}a"
  map_public_ip_on_launch = false
  tags = {
    environment = var.environment
  }
}

# Subnets
resource "aws_subnet" "lab-aws-redes-B-tf-subnet1-AZ2-public" {
  vpc_id              	= aws_vpc.lab-aws-redes-B-tf.id
  cidr_block          	= var.CIDR2_blocks_B_sub1
  availability_zone   	= "${var.region}b"
  map_public_ip_on_launch = true
  tags = {
    environment = var.environment
  }
}

# Subnets
resource "aws_subnet" "lab-aws-redes-B-tf-subnet2-AZ2-private" {
  vpc_id              	= aws_vpc.lab-aws-redes-B-tf.id
  cidr_block          	= var.CIDR2_blocks_B_sub2
  availability_zone   	= "${var.region}b"
  map_public_ip_on_launch = false
  tags = {
    environment = var.environment
  }
}

# Network ACL
resource "aws_default_network_acl" "lab-aws-redes-B-tf-nacl-default" {
  default_network_acl_id = aws_vpc.lab-aws-redes-B-tf.default_network_acl_id

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
    environment = var.environment
  }
}

#Internet Gateway
resource "aws_internet_gateway" "lab-aws-redes-B-tf-IGW" {
  vpc_id = aws_vpc.lab-aws-redes-B-tf.id

  tags = {
    Name = "lab-aws-redes-B-tf-IGW"
  }
}

# Security Group
resource "aws_security_group" "lab-aws-redes-A-tf-sg-default" {
  name    	= "lab-aws-redes-tf Default"
  description = "Allow SSH inbound and all outbound traffic"
  vpc_id  	= aws_vpc.lab-aws-redes-A-tf.id

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
    environment = var.environment
  }
}

#Peering
resource "aws_vpc_peering_connection" "vpc_peering" {
  peer_vpc_id = aws_vpc.lab-aws-redes-B-tf.id
  vpc_id = aws_vpc.lab-aws-redes-A-tf.id
  auto_accept = true
}

# Adicionando rotas nas tabelas de roteamento das VPCs

#Add routes on route_table 
resource "aws_route" "route_to_lab-aws-redes-B-tf" {
  route_table_id         = aws_vpc.lab-aws-redes-A-tf.default_route_table_id
  destination_cidr_block = aws_vpc.lab-aws-redes-B-tf.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

#Add routes on route_table
resource "aws_route" "route_to_lab-aws-redes-A-tf" {
  route_table_id         = aws_vpc.lab-aws-redes-B-tf.default_route_table_id
  destination_cidr_block = aws_vpc.lab-aws-redes-A-tf.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}





# EC2 Instance
resource "aws_instance" "lab-aws-redes-A-tf-ec2" {
    ami= "ami-0c20d88b0021158c6"
    instance_type           = "t2.micro"
    subnet_id               = aws_subnet.lab-aws-redes-A-tf-subnet1-AZ1-public.id
    vpc_security_group_ids  = [aws_security_group.lab-aws-redes-A-tf-sg-default.id] 
    key_name                = var.keypair01
    tags                    = {
                            environment = var.environment
                            Name = "lab-aws-redes-A-tf-ec2"
                            }   
    iam_instance_profile = "role-acesso-ssm"
}

# EC2 Instance
resource "aws_instance" "lab-aws-redes-A2-tf-ec2" {
    ami= "ami-0c20d88b0021158c6"
    instance_type           = "t2.micro"
    subnet_id               = aws_subnet.lab-aws-redes-A-tf-subnet2-AZ1-private.id
    vpc_security_group_ids  = [aws_security_group.lab-aws-redes-A-tf-sg-default.id] 
    key_name                = var.keypair01
    tags                    = {
                            environment = var.environment
                            Name = "lab-aws-redes-A2-tf-ec2"
                            }   
    iam_instance_profile = "role-acesso-ssm"
}