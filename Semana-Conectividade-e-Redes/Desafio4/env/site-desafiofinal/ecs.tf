################################################################################
# Cluster
################################################################################
/*
module "ecs_cluster" {
  source       = "terraform-aws-modules/ecs/aws"
  version      = "~> 5.11"
  cluster_name = var.ecs_name

  task_exec_iam_role_name = var.ecs_iam_role_task_exec
  #Capacity provider - autoscaling groups
  default_capacity_provider_use_fargate = false
  autoscaling_capacity_providers = {
    # On-demand instancess
    app_green = {
      auto_scaling_group_arn         = module.autoscaling["app_green"].autoscaling_group_arn
      managed_termination_protection = "ENABLED"
      managed_scaling = {
        maximum_scaling_step_size = 1
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 2
      }
      default_capacity_provider_strategy = {
        weight = 1
        base   = 1
      }
    }
  }
  tags = var.desc_tags
}
*/
################################################################################
# Service
################################################################################
/*
module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 5.11"

  # Service
  name        = var.ecs_service_1_name
  cluster_arn = module.ecs_cluster.cluster_arn

  # Task Definition
  requires_compatibilities           = ["EC2"]
  cpu                                = 512
  memory                             = 256
  network_mode                       = "bridge"
  desired_count                      = var.as_desired_capacity
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 45

  capacity_provider_strategy = {
    # On-demand instances
    app_green = {
      capacity_provider = module.ecs_cluster.autoscaling_capacity_providers["app_green"].name
      weight            = 1
      base              = 1
    }
  }

  # Container definition(s)
  container_definitions = {
    ("bia") = {
      image  = "${aws_ecr_repository.ecr.repository_url}:latest"
      cpu    = 512
      memory = 256
      #memory_reservation = 256
      essential        = true
      desired_capacity = 2
      health_check = {
        command = ["CMD-SHELL", "curl -f http://localhost:${var.ecs_container_port}/ || exit 1"]
      }
      port_mappings = [
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

      entry_point = ["tail -f /dev/null"]

      # Example image used requires access to write to root filesystem
      readonly_root_filesystem = false

      enable_cloudwatch_logging              = true
      create_cloudwatch_log_group            = true
      cloudwatch_log_group_name              = "/aws/ecs/${var.ecs_name}/bia"
      cloudwatch_log_group_retention_in_days = 3

      log_configuration = {
        logDriver = "awslogs"
      }
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["bia"].arn
      container_name   = "bia"
      container_port   = var.ecs_container_port
    }
  }

  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    alb_http_ingress = {
      type                     = "ingress"
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Service port"
      source_security_group_id = module.alb.security_group_id
    }
  }
  #$$ validar a necessidade desse trecho iam abaixo
  tasks_iam_role_name        = "${var.desc_tags.project}-tasks-role"
  tasks_iam_role_description = "Tasks IAM role"
  tasks_iam_role_policies = {
    ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  }
  tasks_iam_role_statements = [
    {
      actions   = ["ecr:*"]
      resources = ["arn:aws:ecr:::*"]
    }
  ]

  tags       = var.desc_tags
  depends_on = [aws_ecr_repository.ecr]
}*/

################################################################################
# ALB
################################################################################

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

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
/*
module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.5"

  for_each = {
    # On-demand instances
    app_green = {
      instance_type              = "t3.micro"
      use_mixed_instances_policy = false
      mixed_instances_policy     = {}
      user_data                  = <<-EOT
        #!/bin/bash
        cat <<'EOF' >> /etc/ecs/ecs.config
        ECS_CLUSTER=${var.ecs_name}
        ECS_LOGLEVEL=debug
        ECS_CONTAINER_INSTANCE_TAGS=${jsonencode(var.desc_tags)}
        ECS_ENABLE_TASK_IAM_ROLE=true
        EOF
      EOT
    }
  }

  name = "${var.ecs_name}-${each.key}"

  image_id      = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type = each.value.instance_type

  security_groups                 = [module.autoscaling_sg.security_group_id]
  user_data                       = base64encode(each.value.user_data)
  key_name                        = var.ecs_asg_key
  ignore_desired_capacity_changes = true

  create_iam_instance_profile = true
  iam_role_name               = "${var.ecs_name}-as-role"
  iam_role_description        = "ECS role for ${var.ecs_name}"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type   = var.as_health_check_type
  min_size            = var.as_min_size
  max_size            = var.as_max_size
  desired_capacity    = var.as_desired_capacity

  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  # Required for  managed_termination_protection = "ENABLED"
  protect_from_scale_in = true

  # Spot instances
  use_mixed_instances_policy = each.value.use_mixed_instances_policy
  mixed_instances_policy     = each.value.mixed_instances_policy

  scaling_policies = [
    {
      name                    = "scale-in"
      adjustment_type         = "ChangeInCapacity"
      cooldown                = 120
      metric_aggregation_type = "Average"
      scaling_adjustment      = -1
      adjustment_scaling_type = "ChangeInCapacity"
      evaluation_periods      = 2
    },
    {
      name                    = "scale-out"
      adjustment_type         = "ChangeInCapacity"
      cooldown                = 120
      metric_aggregation_type = "Average"
      scaling_adjustment      = 1
      adjustment_scaling_type = "ChangeInCapacity"
      evaluation_periods      = 2
    },
  ]

  tags = var.desc_tags
}*/
/*
# Criação do Cluster ECS
resource "aws_ecs_cluster" "ecs" {
  name = "example-cluster"
}

# Criação do Launch Configuration
resource "aws_launch_configuration" "example" {
  name          = "example-launch-config"
  image_id      = "ami-12345678" # ID da AMI desejada
  instance_type = "t3.micro"      # Tipo de instância desejado

  security_groups = ["${aws_security_group.instance.id}"]
  key_name        = "example-keypair"

  lifecycle {
    create_before_destroy = true
  }

  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.example.name} >> /etc/ecs/ecs.config
              EOF
}

# Criação do Auto Scaling Group
resource "aws_autoscaling_group" "example" {
  name                 = "example-asg"
  launch_configuration = aws_launch_configuration.example.id
  min_size             = 1
  max_size             = 4
  desired_capacity     = 2
  vpc_zone_identifier  = ["subnet-12345678"] # Subnet ID desejada

  # Configurações de Upscaling
  scaling_policy {
    adjustment_type         = "ChangeInCapacity"
    estimated_instance_warmup = 300 # Tempo de espera em segundos para as novas instâncias estarem prontas
    cooldown               = 300 # Tempo de espera em segundos antes de permitir outro escalonamento
    metric_aggregation_type = "Average"
    name                    = "upscaling-policy"
    scaling_adjustment     = 1 # Aumenta em 1 instância
    evaluation_periods     = 3 # Número de períodos de avaliação antes que a ação de escalonamento seja executada
    target_metric_value    = 70 # Percentual de utilização de CPU
    target_tracking_scaling_policy_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
    }
  }

  # Configurações de Downscaling
  scaling_policy {
    adjustment_type         = "ChangeInCapacity"
    estimated_instance_warmup = 300 # Tempo de espera em segundos para as novas instâncias estarem prontas
    cooldown               = 300 # Tempo de espera em segundos antes de permitir outro escalonamento
    metric_aggregation_type = "Average"
    name                    = "downscaling-policy"
    scaling_adjustment     = -1 # Reduz em 1 instância
    evaluation_periods     = 3 # Número de períodos de avaliação antes que a ação de escalonamento seja executada
    target_metric_value    = 20 # Percentual de utilização de CPU
    target_tracking_scaling_policy_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
    }
  }
}

# Regra IAM para permissões ECS
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Anexar política AmazonECSTaskExecutionRolePolicy à função
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Definição de Tarefa (Task Definition)
resource "aws_ecs_task_definition" "example" {
  family                   = "example-task"
  container_definitions    = jsonencode([
    {
      name  = "example-container"
      image = "nginx:latest"
      # Outras configurações do contêiner...
    }
  ])
  
  # Configuração de Placement Constraints para permitir apenas uma tarefa por host
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.instance-type =~ t2.*"
  }
}

# Criação do Serviço ECS
resource "aws_ecs_service" "example" {
  name            = "example-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  desired_count   = 2
  
  # Configuração de estratégia de Placement para permitir apenas uma tarefa por host
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.instance-type =~ t3.*"
  }
}

*/
