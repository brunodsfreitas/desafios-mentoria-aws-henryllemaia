resource "aws_ecs_cluster" "lab_conectividade_bia_app_cluster" {
  name = var.lab_cluster_name
}

# VPC
resource "aws_vpc" "lab-aws-redes-A-tf" {
  cidr_block           = var.CIDR_blocks_A
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    environment = var.environment
    Name        = "lab-aws-redes-A-tf"
  }
}

#internet gateway 1
resource "aws_internet_gateway" "lab-aws-redes-A-tf-igw1" {
  vpc_id = aws_vpc.lab-aws-redes-A-tf.id
  tags = {
    environment = var.environment
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
    Name        = "lab-aws-redes-A-tf-subnet1-AZ1-public-route-table"
  }
}

# Subnets
resource "aws_subnet" "lab-aws-redes-A-tf-subnet1-AZ1-public" {
  vpc_id                  = aws_vpc.lab-aws-redes-A-tf.id
  cidr_block              = var.CIDR_blocks_A_sub1
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    environment = var.environment
  }
}

# Subnets
resource "aws_subnet" "lab-aws-redes-A-tf-subnet2-AZ1-private" {
  vpc_id                  = aws_vpc.lab-aws-redes-A-tf.id
  cidr_block              = var.CIDR_blocks_A_sub2
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  tags = {
    environment = var.environment
  }
}

# Subnets
resource "aws_subnet" "lab-aws-redes-A-tf-subnet1-AZ2-public" {
  vpc_id                  = aws_vpc.lab-aws-redes-A-tf.id
  cidr_block              = var.CIDR_blocks_B_sub1
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
  tags = {
    environment = var.environment
  }
}

# Subnets
resource "aws_subnet" "lab-aws-redes-A-tf-subnet2-AZ2-private" {
  vpc_id                  = aws_vpc.lab-aws-redes-A-tf.id
  cidr_block              = var.CIDR_blocks_B_sub2
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false
  tags = {
    environment = var.environment
  }
}

# Network ACL
resource "aws_default_network_acl" "lab-aws-redes-A-tf-nacl-default" {
  default_network_acl_id = aws_vpc.lab-aws-redes-A-tf.default_network_acl_id

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

  tags = {
    environment = var.environment
  }
}

resource "aws_ecs_task_definition" "bia_app_task" {
  family = var.app_task_family
  container_definitions = <<DEFINITION
  [
    {
        "name": "${var.app_task_family}",
        "image": "${var.ecr_repo_url}",
        "essential": true,
        "portMappings: [
            {
                "container_port": ${var.container_port},
                "host_port": ${var.container_port}
            }
        ],
        "memory": 512,
        "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["EC2"]
  network_mode = "bridge"
  memory = 512
  cpu = 256
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = var.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_alb" "bia_load_balancer" {
  name = var.bia_load_balancer_name
  load_balancer_type = "application"
  subnets = [
    "${subnet_id}",
    "${subnet2_id}"
  ]
  security_groups = ["${aws_security_group.sg_load_balancer.id}"]
}

resource "aws_security_group" "sg_load_balancer" {
  ingress = {
    from_port=80
    to_port=80
    protocol="tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress = {
    from_port=0
    to_port=0
    protocol=-1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "tg_bia" {
  name = var.target_group_name
  port = var.container_port
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = aws_vpc.lab-aws-redes-A-tf.id
}

resource "aws_lb_listener" "listener80" {
  load_balancer_arn = aws_alb.bia_load_balancer.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg_bia.arn
  }
}

resource "aws_ecs_service" "bia_ecs_service" {
  name = var.bia_service_name
  cluster = aws_ecs_cluster.lab_conectividade_bia_app_cluster.id
  task_definition = aws_ecs_task_definition.bia_app_task.arn
  launch_type = "EC2"
  desired_count = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.tg_bia.arn
    container_name = aws_ecs_task_definition.bia_app_task.family
    container_port = var.container_port
  }

  network_configuration {
    subnets = ["${subnet.id}", "${subnet2.id}"]
    assign_public_ip = false
    security_groups = ["${aws_security_group.sg_service.id}"]
  }
}

resource "aws_security_group" "sg_service" {
  ingress = {
    from_port=0
    to_port=0
    protocol=-1
    security_groups = ["${aws_security_group.sg_load_balancer.id}"]
  }
  egress = {
    from_port=0
    to_port=0
    protocol=-1
    cidr_blocks = ["0.0.0.0/0"]
  }
}