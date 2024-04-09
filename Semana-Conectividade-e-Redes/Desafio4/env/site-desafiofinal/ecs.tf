
################################################################################
# Cluster
################################################################################

module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.11"

  cluster_name = var.ecs_name

  task_exec_iam_role_name = "role-acesso-ssm"

  # Capacity provider - autoscaling groups
  default_capacity_provider_use_fargate = false
  autoscaling_capacity_providers = {
    # On-demand instances
    workers_green = {
      auto_scaling_group_arn         = module.autoscaling["workers_green"].autoscaling_group_arn
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 2
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 70
      }

      default_capacity_provider_strategy = {
        weight = 70
        base   = 20
      }
    }
    # Spot instances
    #ex_2 = {
    #  auto_scaling_group_arn         = module.autoscaling["ex_2"].autoscaling_group_arn
    #  managed_termination_protection = "ENABLED"
    #
    #  managed_scaling = {
    #    maximum_scaling_step_size = 15
    #    minimum_scaling_step_size = 5
    #    status                    = "ENABLED"
    #    target_capacity           = 90
    #  }
    #
    #  default_capacity_provider_strategy = {
    #    weight = 40
    #  }
    #}
  }
  tags = var.desc_tags
}

################################################################################
# Service
################################################################################

module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 5.11"

  # Service
  name        = var.ecs_service_1_name
  cluster_arn = module.ecs_cluster.cluster_arn

  # Task Definition
  requires_compatibilities = ["EC2"]
  cpu = 768  # Valor em unidades de CPU
  memory = 768  # Valor em megabytes
  network_mode = "bridge"
  capacity_provider_strategy = {
    # On-demand instances
    workers_green = {
      capacity_provider = module.ecs_cluster.autoscaling_capacity_providers["workers_green"].name
      weight            = 1
      base              = 1
    }
  }

  #volume = {
  #  my-vol = {}
  #}

  # Container definition(s)
  container_definitions = {
    ("bia") = {
      #image = "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest"
      image = "${aws_ecr_repository.ecr.repository_url}:latest"
      #993087404463.dkr.ecr.us-east-2.amazonaws.com/semanaconectividadeaws_ecr
      port_mappings = [
        {
          name          = "bia"
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      cpu = 256  # Valor em unidades de CPU (1 vCPU = 1024 unidades de CPU)
      memory = 256  # Valor em megabytes

      #mount_points = [
      #  {
      #    sourceVolume  = "my-vol",
      #    containerPath = "/var/www/my-vol"
      #  }
      #]

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
      container_port   = 80
    }
  }

  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    alb_http_ingress = {
      type                     = "ingress"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.alb.security_group_id
    }
  }

  tags = var.desc_tags
  depends_on = [aws_ecr_repository.ecr]
}

################################################################################
# Supporting Resources
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
      from_port   = 80
      to_port     = 80
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
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "bia"
      }
    }
  }

  target_groups = {
    bia = {
      backend_protocol                  = "HTTP"
      backend_port                      = 80
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




module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.5"

  for_each = {
    # On-demand instances
    workers_green = {
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

  # https://github.com/hashicorp/terraform-provider-aws/issues/12582
  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  # Required for  managed_termination_protection = "ENABLED"
  protect_from_scale_in = true

  # Spot instances
  use_mixed_instances_policy = each.value.use_mixed_instances_policy
  mixed_instances_policy     = each.value.mixed_instances_policy

  tags = var.desc_tags
}

module "autoscaling_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.ecs_name}-sg"
  description = "Autoscaling group security group"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]

  tags = var.desc_tags
}

################################################################################
# Data
################################################################################

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html#ecs-optimized-ami-linux
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}