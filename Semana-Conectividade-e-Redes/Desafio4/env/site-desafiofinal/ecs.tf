################################################################################
# Cluster
################################################################################
resource "aws_ecs_cluster" "ecs" {
  name = var.ecs_name
}

### Criação do Launch Template
resource "aws_launch_template" "lc_bia" {
  name                   = "lc-bia"
  image_id               = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type          = "t3.micro" # Tipo de instância desejado
  vpc_security_group_ids = [module.autoscaling_sg.security_group_id]
  #key_name               = var.ecs_asg_key
  iam_instance_profile {
    arn = aws_iam_instance_profile.bia_service_instance_profile.arn
  }
  lifecycle {
    create_before_destroy = false
  }
  user_data = base64encode(<<-EOT
        #!/bin/bash
        cat <<'EOF' >> /etc/ecs/ecs.config
        ECS_CLUSTER=${var.ecs_name}
        ECS_LOGLEVEL=debug
        ECS_CONTAINER_INSTANCE_TAGS=${jsonencode(var.desc_tags)}
        ECS_ENABLE_TASK_IAM_ROLE=true
        yum update && yum install -y ec2-instance-connect
        EOF
      EOT
  )
}
################################################################################
# Services
################################################################################
resource "aws_ecs_service" "service_bia" {
  name                = var.ecs_service_1_name
  cluster             = var.ecs_name
  task_definition     = aws_ecs_task_definition.bia_TD.arn
  scheduling_strategy = "DAEMON"
  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    target_group_arn = module.alb.target_groups["bia"]["arn"]
    container_name   = "bia_TD"
    container_port   = var.ecs_container_port
  }
}
# Task Definition
resource "aws_ecs_task_definition" "bia_TD" {
  family = "bia-TD"
  container_definitions = jsonencode([
    {
      name                                   = "bia_TD"
      image                                  = "${aws_ecr_repository.ecr.repository_url}:latest"
      cpu                                    = 512
      memory                                 = 256
      essential                              = true
      entry_point                            = ["tail -f /dev/null"]
      enable_cloudwatch_logging              = true
      create_cloudwatch_log_group            = true
      cloudwatch_log_group_name              = "/aws/ecs/${var.ecs_name}/bia"
      cloudwatch_log_group_retention_in_days = 3
      log_configuration = {
        logDriver = "awslogs"
      }
      portMappings = [
        {
          name          = "bia"
          containerPort = var.ecs_container_port
          protocol      = "tcp"
          hostPort      = var.ecs_container_port
        }
      ]
      environment = [
        {
          name  = "DB_USER"
          value = var.rds_username
        },
        {
          name  = "DB_PWD"
          value = var.rds_password
        },
        {
          name  = "DB_HOST"
          value = "${module.rds.db_instance_address}"
        },
        {
          name  = "DB_PORT"
          value = "5432"
        }
      ]
    }
  ])
}
################################################################################
# ALB
################################################################################

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.9"

  name = "${var.ecs_name}-alb"

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # For example only
  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = var.ecs_alb_port
      to_port     = var.ecs_alb_port
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  listeners = {
    bia_http = {
      port     = var.ecs_alb_port
      protocol = "HTTP"

      forward = {
        target_group_key = "bia"
      }
    }
  }

  target_groups = {
    bia = {
      backend_protocol                  = "HTTP"
      backend_port                      = var.ecs_container_port
      target_type                       = "instance"
      deregistration_delay              = 10
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 10
        unhealthy_threshold = 2
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }

  tags = var.desc_tags
}

################################################################################
# ASG
################################################################################
resource "aws_autoscaling_group" "bia_asg" {
  name                      = "bia_asg"
  min_size                  = 1
  max_size                  = 4
  desired_capacity          = 2
  vpc_zone_identifier       = module.vpc.private_subnets
  health_check_grace_period = 45
  launch_template {
    id      = aws_launch_template.lc_bia.id
    version = "$Latest" # Pega ultima versão
  }
}
### ASG Policies
resource "aws_autoscaling_policy" "bia_scale_down" {
  name                   = "bia_scale_down"
  autoscaling_group_name = aws_autoscaling_group.bia_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}
resource "aws_cloudwatch_metric_alarm" "bia_scale_down" {
  alarm_description   = "Monitors CPU utilization for BIA ASG"
  alarm_actions       = [aws_autoscaling_policy.bia_scale_down.arn]
  alarm_name          = "bia_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "10"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.bia_asg.name
  }
}
resource "aws_autoscaling_policy" "bia_scale_up" {
  name                   = "bia_scale_up"
  autoscaling_group_name = aws_autoscaling_group.bia_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}
resource "aws_cloudwatch_metric_alarm" "bia_scale_up" {
  alarm_description   = "Monitors CPU utilization for BIA ASG"
  alarm_actions       = [aws_autoscaling_policy.bia_scale_up.arn]
  alarm_name          = "bia_scale_up"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "70"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.bia_asg.name
  }
}

################################################################################
# EC2 Instances
################################################################################
resource "aws_instance" "bastion_host" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type #"t3.micro"
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [module.bastion_host_sg.security_group_id]
  key_name               = var.instance_keyname #"ssh keypair"
  iam_instance_profile   = var.instance_iam_profile
  tags                   = merge({ "Name" = "${var.instance_name}-instance" }, var.desc_tags)
  user_data              = <<-EOF
#!/bin/bash
sudo yum update -y  
sudo yum install -y git wget
EOF
}

################################################################################
# Route53 - Records
################################################################################
resource "aws_route53_record" "bia" {
  zone_id = var.domain
  name    = "desafio4"
  type    = "CNAME"
  ttl     = 300
  records = [module.alb.dns_name]
}