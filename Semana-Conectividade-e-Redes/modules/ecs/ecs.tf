resource "aws_ecs_cluster" "lab_conectividade_bia_app_cluster" {
  name = var.lab_cluster_name
  tags = merge({ "Name" = "${var.desc_tags.project}-vpc" }, var.desc_tags)
}

# VPC
resource "aws_vpc" "lab_conectividade_bia-tf" {
  cidr_block           = var.cidr_block_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.desc_tags
}

#internet gateway 1
resource "aws_internet_gateway" "lab_conectividade_bia-tf-igw1" {
  vpc_id = aws_vpc.lab_conectividade_bia-tf.id
  tags   = var.desc_tags
}

#route table 1
resource "aws_default_route_table" "lab_conectividade_bia-tf-subnet1-AZ1-public-route-table" {
  default_route_table_id = aws_vpc.lab_conectividade_bia-tf.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_conectividade_bia-tf-igw1.id
  }

  tags = var.desc_tags
}

# Subnets
resource "aws_subnet" "lab_conectividade_bia-tf-subnet1-AZ1-public" {
  vpc_id                  = aws_vpc.lab_conectividade_bia-tf.id
  cidr_block              = var.cidr_blocks_subnets[0]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true
  tags                    = var.desc_tags
}

# Subnets
resource "aws_subnet" "lab_conectividade_bia-tf-subnet2-AZ1-private" {
  vpc_id                  = aws_vpc.lab_conectividade_bia-tf.id
  cidr_block              = var.cidr_blocks_subnets[2]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false
  tags                    = var.desc_tags
}

# Subnets
resource "aws_subnet" "lab_conectividade_bia-tf-subnet1-AZ2-public" {
  vpc_id                  = aws_vpc.lab_conectividade_bia-tf.id
  cidr_block              = var.cidr_blocks_subnets[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true
  tags                    = var.desc_tags
}

# Subnets
resource "aws_subnet" "lab_conectividade_bia-tf-subnet2-AZ2-private" {
  vpc_id                  = aws_vpc.lab_conectividade_bia-tf.id
  cidr_block              = var.cidr_blocks_subnets[3]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false
  tags                    = var.desc_tags
}

# Network ACL
resource "aws_default_network_acl" "lab_conectividade_bia-tf-nacl-default" {
  default_network_acl_id = aws_vpc.lab_conectividade_bia-tf.default_network_acl_id

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

  tags = var.desc_tags
}

resource "aws_ecs_task_definition" "bia_app_task" {
  family                   = var.app_task_family
  container_definitions    = <<DEFINITION
  [
    {
        "name": "${var.app_task_name}",
        "image": "${var.ecr_repo_url}",
        "essential": true,
        "portMappings": [
            {
                "containerPort": ${var.container_port},
                "hostPort": ${var.container_port}
            }
        ],
        "memory": 512,
        "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  tags                     = var.desc_tags
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = var.desc_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_alb" "bia_load_balancer" {
  name               = var.bia_load_balancer_name
  load_balancer_type = "application"
  subnets = [
    "${aws_subnet.lab_conectividade_bia-tf-subnet1-AZ1-public.id}",
    "${aws_subnet.lab_conectividade_bia-tf-subnet1-AZ2-public.id}"
  ]
  security_groups = ["${aws_security_group.sg_load_balancer.id}"]
  tags            = var.desc_tags
}

resource "aws_security_group" "sg_load_balancer" {
  description = "sg_load_balancer"
  vpc_id      = aws_vpc.lab_conectividade_bia-tf.id
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
  tags = var.desc_tags
}

resource "aws_lb_target_group" "tg_bia" {
  name        = var.target_group_name
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.lab_conectividade_bia-tf.id
  tags        = var.desc_tags
}

resource "aws_lb_listener" "listener80" {
  load_balancer_arn = aws_alb.bia_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_bia.arn
  }
  tags = var.desc_tags
}

resource "aws_security_group" "sg_service" {
  description = "sg_service"
  vpc_id      = aws_vpc.lab_conectividade_bia-tf.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.desc_tags
}

resource "aws_launch_template" "this" {
  name          = "${var.desc_tags.project}-tpl"
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name      = var.key_name != null ? var.key_name : null
  user_data     = filebase64("${path.module}/ec2-init.sh")
  iam_instance_profile {
    name = var.iam_instance_profile
  }
  #network_interfaces {
  #  associate_public_ip_address = true
  #  security_groups             = [aws_security_group.sg_service.id]
  #}
  #security_group_names = [aws_security_group.sg_service.name]
  vpc_security_group_ids = [aws_security_group.sg_service.id]

  tag_specifications {
    resource_type = "instance"
    tags          = merge({ "ResourceName" = "${var.desc_tags.project}-tpl" }, var.desc_tags)
  }
  update_default_version = true 
  depends_on = [aws_security_group.sg_service]
}

resource "aws_autoscaling_group" "this" {

  name                      = "${var.desc_tags.project}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_grace_period = 300
  health_check_type         = var.asg_health_check_type
  #availability_zones = var.availability_zones #["us-east-1a"]
  vpc_zone_identifier = [aws_subnet.lab_conectividade_bia-tf-subnet1-AZ1-public.id, aws_subnet.lab_conectividade_bia-tf-subnet1-AZ2-public.id]
  target_group_arns   = [aws_lb_target_group.tg_bia.arn]

  #enabled_metrics = [
  #  "GroupMinSize",
  #  "GroupMaxSize",
  #  "GroupDesiredCapacity",
  #  "GroupInServiceInstances",
  #  "GroupTotalInstances"
  #]

  #metrics_granularity = "1Minute"

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }
  depends_on = [aws_alb.bia_load_balancer]
}

resource "aws_ecs_service" "bia_ecs_service" {
  name            = var.bia_service_name
  cluster         = aws_ecs_cluster.lab_conectividade_bia_app_cluster.id
  task_definition = aws_ecs_task_definition.bia_app_task.arn
  launch_type     = "EC2"
  desired_count   = 1
  scheduling_strategy = "REPLICA"
  #iam_role = aws_iam_role.ecs_task_execution_role.arn

  load_balancer {
    target_group_arn = aws_lb_target_group.tg_bia.arn
    container_name   = aws_ecs_task_definition.bia_app_task.family
    container_port   = var.container_port
  }

  #network_configuration {
  #  subnets          = [aws_subnet.lab_conectividade_bia-tf-subnet1-AZ1-public.id, aws_subnet.lab_conectividade_bia-tf-subnet1-AZ2-public.id]
  #  assign_public_ip = true
  #  security_groups  = [aws_security_group.sg_service.id]
  #}
  tags = var.desc_tags

  depends_on = [ aws_iam_role_policy_attachment.ecs_task_execution_role_policy, aws_autoscaling_group.this ]
}