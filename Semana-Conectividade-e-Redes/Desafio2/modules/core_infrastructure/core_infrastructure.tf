# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge({ "Name" = "${var.desc_tags.project}" }, var.desc_tags)
}

#Elastic IP 1
resource "aws_eip" "eip_ngw1" {
  domain = "vpc"
  tags   = merge({ "Name" = "${var.desc_tags.project}" }, var.desc_tags)
}

#Elastic IP 2
resource "aws_eip" "eip_ngw2" {
  domain = "vpc"
  tags   = merge({ "Name" = "${var.desc_tags.project}" }, var.desc_tags)
}

#internet gateway 1
resource "aws_internet_gateway" "igw1" {
  vpc_id     = aws_vpc.this.id
  tags       = merge({ "Name" = "${var.desc_tags.project}-igw1" }, var.desc_tags)
  depends_on = [aws_vpc.this]
}

#nat gateway 1
resource "aws_nat_gateway" "ngw1" {
  allocation_id = aws_eip.eip_ngw1.id
  subnet_id     = aws_subnet.subnet1a-public.id
  tags          = merge({ "Name" = "${var.desc_tags.project}-ngw1-1a" }, var.desc_tags)
}

#nat gateway 2
resource "aws_nat_gateway" "ngw2" {
  allocation_id = aws_eip.eip_ngw2.id
  subnet_id     = aws_subnet.subnet1b-public.id
  tags          = merge({ "Name" = "${var.desc_tags.project}-ngw2-1b" }, var.desc_tags)
}

#Route Table default
resource "aws_default_route_table" "rt-default" {
  default_route_table_id = aws_vpc.this.default_route_table_id
  tags                   = var.desc_tags
  route                  = []
}

#Route Table publica
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.this.id
  tags   = merge({ "Name" = "${var.desc_tags.project}-rt_public" }, var.desc_tags)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }
  route {
    cidr_block = aws_vpc.this.cidr_block
    gateway_id = "local"
  }
}

#Route Table privada 1
resource "aws_route_table" "rt_subnet2a-private" {
  vpc_id = aws_vpc.this.id
  tags   = merge({ "Name" = "${var.desc_tags.project}-rt_subnet2a-private" }, var.desc_tags)
  route {
    cidr_block = aws_vpc.this.cidr_block
    gateway_id = "local"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw1.id
  }
}

#Route Table privada 2
resource "aws_route_table" "rt_subnet2b-private" {
  vpc_id = aws_vpc.this.id
  tags   = merge({ "Name" = "${var.desc_tags.project}-rt_subnet2b-private" }, var.desc_tags)
  route {
    cidr_block = aws_vpc.this.cidr_block
    gateway_id = "local"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw2.id
  }
}

#Route Table Association
resource "aws_route_table_association" "rt_association_subnet1a-public" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
  subnet_id      = aws_subnet.subnet1a-public.id
  route_table_id = aws_route_table.rt_public.id

  depends_on = [
    aws_subnet.subnet1a-public,
    aws_route_table.rt_public,
  ]
}

#Route Table Association
resource "aws_route_table_association" "rt_association_subnet1b-public" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
  subnet_id      = aws_subnet.subnet1b-public.id
  route_table_id = aws_route_table.rt_public.id

  depends_on = [
    aws_subnet.subnet1b-public,
    aws_route_table.rt_public,
  ]
}

#Route Table Association
resource "aws_route_table_association" "rt_association_subnet2a-private" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
  subnet_id      = aws_subnet.subnet2a-private.id
  route_table_id = aws_route_table.rt_subnet2a-private.id

  depends_on = [
    aws_subnet.subnet2a-private,
    aws_route_table.rt_subnet2a-private,
  ]
}

#Route Table Association
resource "aws_route_table_association" "rt_association_subnet2b-private" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
  subnet_id      = aws_subnet.subnet2b-private.id
  route_table_id = aws_route_table.rt_subnet2b-private.id

  depends_on = [
    aws_subnet.subnet2b-private,
    aws_route_table.rt_subnet2b-private,
  ]
}

#Route Table Association 
resource "aws_route_table_association" "rt_association_ngw1" {
  subnet_id      = aws_subnet.subnet2a-private.id
  route_table_id = aws_route_table.rt_subnet2a-private.id
}

#Route Table Association 
resource "aws_route_table_association" "rt_association_ngw2" {
  subnet_id      = aws_subnet.subnet2b-private.id
  route_table_id = aws_route_table.rt_subnet2b-private.id
}

# Subnets
resource "aws_subnet" "subnet1a-public" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
  vpc_id                                      = aws_vpc.this.id
  cidr_block                                  = var.cidr_blocks_subnets[0]
  availability_zone                           = var.availability_zones[0]
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true
  tags                                        = merge({ "Name" = "${var.desc_tags.project}-subnet1a-public" }, var.desc_tags)
}

# Subnets
resource "aws_subnet" "subnet2a-private" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.cidr_blocks_subnets[2]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false
  tags                    = merge({ "Name" = "${var.desc_tags.project}-subnet2a-private" }, var.desc_tags)
}

# Subnets
resource "aws_subnet" "subnet1b-public" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.cidr_blocks_subnets[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true
  tags                    = merge({ "Name" = "${var.desc_tags.project}-subnet1b-public" }, var.desc_tags)
}

# Subnets
resource "aws_subnet" "subnet2b-private" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.cidr_blocks_subnets[3]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false
  tags                    = merge({ "Name" = "${var.desc_tags.project}-subnet2b-private" }, var.desc_tags)
}

# Network ACL
resource "aws_default_network_acl" "this" {
  default_network_acl_id = aws_vpc.this.default_network_acl_id
  tags                   = merge({ "Name" = "${var.desc_tags.project}" }, var.desc_tags)
  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

# Cluster ECS
resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster_name
  tags = merge({ "Name" = "${var.desc_tags.project}" }, var.desc_tags)
}

# Security Group
resource "aws_security_group" "sg_load_balancer" {
  description = "sg_load_balancer"
  vpc_id      = aws_vpc.this.id
  tags        = merge({ "Name" = "${var.desc_tags.project}" }, var.desc_tags)
  ingress {
    from_port   = 80
    to_port     = 80
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

# Application Load Balancer
resource "aws_alb" "this" {
  name = "${var.desc_tags.project}-alb"
  #internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_load_balancer.id]
  tags               = var.desc_tags
  subnets = [
    aws_subnet.subnet1a-public.id,
    aws_subnet.subnet1b-public.id
  ]
}

# Security Group
resource "aws_security_group" "sg_services" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
  description = "sg_services"
  vpc_id      = aws_vpc.this.id
  tags        = merge({ "Name" = "${var.desc_tags.project}" }, var.desc_tags)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch Template
resource "aws_launch_template" "this" {
  name                   = "${var.desc_tags.project}-tpl"
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name != null ? var.key_name : null
  update_default_version = true
  vpc_security_group_ids = [aws_security_group.sg_services.id]
  iam_instance_profile {
    name = var.iam_instance_profile
  }
  tag_specifications {
    resource_type = "instance"
    tags          = merge({ "ResourceName" = "${var.desc_tags.project}-tpl" }, var.desc_tags)
  }
  user_data = base64encode(<<DEFINITION
#!/bin/bash
echo "ECS_CLUSTER=${var.ecs_cluster_name}" >> /etc/ecs/ecs.config
DEFINITION
  )
}

# Autoscaling Group
resource "aws_autoscaling_group" "this" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group

  name                      = "${var.desc_tags.project}-asg"
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  health_check_grace_period = 60
  health_check_type         = "ELB"
  default_cooldown          = 60
  vpc_zone_identifier       = [aws_subnet.subnet2b-private.id,aws_subnet.subnet2a-private.id]
  target_group_arns         = []
  depends_on                = [aws_alb.this]
  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }
  tag {
    key                 = "Name"
    value               = var.desc_tags.project
    propagate_at_launch = true
  }
}

# Security Group default
resource "aws_security_group" "sg_ec2_default" {
  name        = "${var.desc_tags.project}-sg_ec2_default"
  description = "Allow SSH inbound and all outbound traffic"
  vpc_id      = aws_vpc.this.id
  tags        = var.desc_tags
  ingress {
    from_port   = 22
    to_port     = 22
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

# EC2 Instance
resource "aws_instance" "bastion_host" {
  ami                    = var.image_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet1a-public.id
  vpc_security_group_ids = [aws_security_group.sg_ec2_default.id]
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile
  tags                   = merge({ "Name" = "${var.desc_tags.project}-bastion_host" }, var.desc_tags)
  user_data              = <<-EOF
#!/bin/bash
sudo yum update -y  
sudo yum install -y git wget
# Baixa a versão mais recente do Terraform
TERRAFORM_VERSION=$(curl -s https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].builds[].url' | grep linux_amd64 | sort -r | head -n 1)
wget $TERRAFORM_VERSION -O /tmp/terraform.zip
unzip /tmp/terraform.zip -d /usr/local/bin/
rm /tmp/terraform.zip
sudo git clone https://github.com/brunodsfreitas/desafios-mentoria-aws-henryllemaia.git
EOF
}
