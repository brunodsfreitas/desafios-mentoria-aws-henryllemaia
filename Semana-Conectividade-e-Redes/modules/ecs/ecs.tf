# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge({ "Name" = "${var.desc_tags.project}" }, var.desc_tags)
}

#internet gateway 1
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.this.id
  tags   = merge({ "Name" = "${var.desc_tags.project}" }, var.desc_tags)
}

#Route Table default
resource "aws_default_route_table" "subnet1-AZ1-public-route-table" {
  default_route_table_id = aws_vpc.this.default_route_table_id
  tags                   = var.desc_tags
  route                  = []
}

#Route Table publica
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.this.id
  tags   = merge({ "Name" = "${var.desc_tags.project}" }, var.desc_tags)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }
  route {
    cidr_block = aws_vpc.this.cidr_block
    gateway_id = "local"
  }
}

#Route Table privada
resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.this.id
  tags   = merge({ "Name" = "${var.desc_tags.project}" }, var.desc_tags)
  route {
    cidr_block = aws_vpc.this.cidr_block
    gateway_id = "local"
  }
}

#Route Table Association
resource "aws_route_table_association" "rt_association_publicAZ1" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
  subnet_id      = aws_subnet.subnet1-AZ1-public.id
  route_table_id = aws_route_table.rt_public.id

  depends_on = [
    aws_subnet.subnet1-AZ1-public,
    aws_route_table.rt_public,
  ]
}

#Route Table Association
resource "aws_route_table_association" "rt_association_publicAZ2" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
  subnet_id      = aws_subnet.subnet1-AZ2-public.id
  route_table_id = aws_route_table.rt_public.id

  depends_on = [
    aws_subnet.subnet1-AZ2-public,
    aws_route_table.rt_public,
  ]
}

#Route Table Association
resource "aws_route_table_association" "rt_association_privateAZ1" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
  subnet_id      = aws_subnet.subnet2-AZ1-private.id
  route_table_id = aws_route_table.rt_private.id

  depends_on = [
    aws_subnet.subnet2-AZ1-private,
    aws_route_table.rt_private,
  ]
}

#Route Table Association
resource "aws_route_table_association" "rt_association_privateAZ2" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
  subnet_id      = aws_subnet.subnet2-AZ2-private.id
  route_table_id = aws_route_table.rt_private.id

  depends_on = [
    aws_subnet.subnet2-AZ2-private,
    aws_route_table.rt_private,
  ]
}

# Subnets
resource "aws_subnet" "subnet1-AZ1-public" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
  vpc_id                                      = aws_vpc.this.id
  cidr_block                                  = var.cidr_blocks_subnets[0]
  availability_zone                           = var.availability_zones[0]
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true
  tags                                        = merge({ "Name" = "${var.desc_tags.project}" }, var.desc_tags)
}

# Subnets
resource "aws_subnet" "subnet2-AZ1-private" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.cidr_blocks_subnets[2]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false
  tags                    = merge({ "Name" = "${var.desc_tags.project}" }, var.desc_tags)
}

# Subnets
resource "aws_subnet" "subnet1-AZ2-public" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.cidr_blocks_subnets[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true
  tags                    = merge({ "Name" = "${var.desc_tags.project}" }, var.desc_tags)
}

# Subnets
resource "aws_subnet" "subnet2-AZ2-private" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.cidr_blocks_subnets[3]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false
  tags                    = merge({ "Name" = "${var.desc_tags.project}" }, var.desc_tags)
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

# Application Load Balancer
resource "aws_alb" "this" {
  name               = var.load_balancer_name
  load_balancer_type = var.lb_type
  security_groups    = ["${aws_security_group.sg_load_balancer.id}"]
  tags               = var.desc_tags
  subnets = [
    "${aws_subnet.subnet1-AZ1-public.id}",
    "${aws_subnet.subnet1-AZ2-public.id}"
  ]
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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group
resource "aws_security_group" "sg_service" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
  description = "sg_service"
  vpc_id      = aws_vpc.this.id
  tags        = merge({ "Name" = "${var.desc_tags.project}" }, var.desc_tags)
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      aws_subnet.subnet1-AZ1-public.cidr_block,
      aws_subnet.subnet1-AZ2-public.cidr_block,
      aws_subnet.subnet2-AZ1-private.cidr_block,
      aws_subnet.subnet2-AZ2-private.cidr_block
    ]
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
  #depends_on             = [aws_security_group.sg_service]
  vpc_security_group_ids = [aws_security_group.sg_service.id]
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
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_grace_period = var.asg_health_check_grace_period
  health_check_type         = var.asg_health_check_type
  vpc_zone_identifier       = [aws_subnet.subnet1-AZ1-public.id, aws_subnet.subnet1-AZ2-public.id]
  target_group_arns         = []
  metrics_granularity       = "1Minute"
  depends_on                = [aws_alb.this]
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
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