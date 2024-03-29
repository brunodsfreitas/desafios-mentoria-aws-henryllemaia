#Task Definition
resource "aws_ecs_task_definition" "this" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
  family                   = var.td_task_family
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  memory                   = var.td_memory
  cpu                      = var.td_cpu
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  tags                     = var.desc_tags
  container_definitions    = <<DEFINITION
  [
    {
        "name": "${var.td_task_family}",
        "image": "brunodsfreitas/aws-desafio2-tosios:latest",
        "essential": true,
        "portMappings": [
            {
                "containerPort": ${var.application_container_port},
                "hostPort": ${var.application_container_port},
                "protocol": "tcp"
            }
        ],
        "memory": ${var.td_memory},
        "cpu": ${var.td_cpu}
    }
  ]
  DEFINITION
}

# IAM Role for Task Execution
resource "aws_iam_role" "ecs_task_execution_role" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
  name               = "${var.td_task_name}-task-definition-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = var.desc_tags
}

# IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Service
resource "aws_ecs_service" "app" {
  name                = var.service_name
  cluster             = var.cluster_id_for_service
  task_definition     = aws_ecs_task_definition.this.arn
  launch_type         = "EC2"
  desired_count       = 1
  scheduling_strategy = "REPLICA"
  tags                = var.desc_tags
  depends_on          = [aws_iam_role_policy_attachment.ecs_task_execution_role_policy]
  load_balancer {
    target_group_arn = aws_lb_target_group.play.arn
    container_name   = aws_ecs_task_definition.this.family
    container_port   = var.application_container_port
  }
  placement_constraints {
    type = "distinctInstance"
  }
  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }
}

#Autoscaling Group Attachment
resource "aws_autoscaling_attachment" "service_1" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_attachment
  autoscaling_group_name = var.autoscaling_group_name
  lb_target_group_arn    = var.app_qrcode_target_group_arn
}

#DNS Record
resource "aws_route53_record" "alb_dns_record" {
  zone_id = var.domain
  name    = "play"
  type    = "CNAME"
  ttl     = 300
  records = [var.alb_dns_name_to_dns_record]
}

#DNS Record
resource "aws_route53_record" "alb_dns_record_bastion" {
  zone_id = var.domain
  name    = "bastion-host"
  type    = "A"
  ttl     = 300
  records = [var.bastion_host_instance_public_ip]
}

# Target Group
resource "aws_lb_target_group" "play" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
  name                 = var.target_group_name
  port                 = var.application_container_port
  protocol             = "HTTP"
  target_type          = "instance"
  vpc_id               = var.vpc_id_for_tg
  deregistration_delay = 60
  tags                 = var.desc_tags
}

# Rule Listener
resource "aws_lb_listener_rule" "rule_play" {
  listener_arn = var.app_qrcode_listener_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.play.arn
  }

  condition {
    host_header {
      values = ["play.brunofreitas.tec.br"]
    }
  }
}

# Target Group extra desafio 2
resource "aws_lb_target_group" "desafio2" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
  name                 = "TG-desafio2"
  port                 = 3001
  protocol             = "HTTP"
  target_type          = "instance"
  vpc_id               = var.vpc_id_for_tg
  deregistration_delay = 60
  tags                 = var.desc_tags
}

# Rule Listener extra desafio 2
#resource "aws_lb_listener_rule" "desafio2" {
#  listener_arn = var.app_qrcode_listener_arn
#  priority     = 105
#
#  action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.desafio2.arn
#  }
#
#  condition {
#    host_header {
#      values = ["desafio2.brunofreitas.tec.br"]
#    }
#  }
#}

resource "aws_lb_target_group_attachment" "example" {
  target_group_arn = aws_lb_target_group.desafio2.arn
  target_id        = var.app_bia_instance_id
}