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
        "name": "${var.td_task_name}",
        "image": "${var.ecr_repo_url}",
        "essential": true,
        "portMappings": [
            {
                "containerPort": ${var.db_application_container_port},
                "hostPort": ${var.db_application_container_port},
                "protocol": "tcp"
            }
        ],
        "environment": [
            {
              "name": "POSTGRES_DB",
              "value": "${var.db_name}"
            },
            {
              "name": "POSTGRES_USER",
              "value": "${var.db_username}"
            },
            {
              "name": "POSTGRES_PASSWORD",
              "value": "${var.db_password}"
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
  name               = var.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = var.desc_tags
}

# IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Service
resource "aws_ecs_service" "db" {
  name                = var.service_name
  cluster             = var.cluster_id_for_service
  task_definition     = aws_ecs_task_definition.this.arn
  launch_type         = "EC2"
  desired_count       = 1
  scheduling_strategy = "REPLICA"
  tags                = var.desc_tags
  depends_on          = [aws_iam_role_policy_attachment.ecs_task_execution_role_policy]
}

# Target Group
resource "aws_lb_target_group" "this" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
  name        = var.target_group_name
  port        = var.db_application_container_port
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc_id_for_tg
  tags        = var.desc_tags
}

#Autoscaling Group Attachment
resource "aws_autoscaling_attachment" "service_1" { #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_attachment
  autoscaling_group_name = var.autoscaling_group_name
  lb_target_group_arn    = aws_lb_target_group.this.arn
}