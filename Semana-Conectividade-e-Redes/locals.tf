locals {

  # Project
  desc_tags = {
    project      = "SemanaConectividadeAWS"
    orgunit      = "Desafio1"
    businessunit = "Matriz"
    costcenter   = "estudos"
    appid        = "01.01"
    appname      = "ClusterBia"
    desc         = "ECS com EC2 com NatGateway"
    tier         = "developer"
    createdby    = "BrunoFreitas"
    #createdon    = timeadd(timestamp(), "-3h")
  }
  # General 
  region  = "us-east-2"
  profile = "default"

  ecr_repo_name = "lab_semana_conectividade"

  lab_cluster_name             = "lab-bia-cluster"
  availability_zones           = ["us-east-2a", "us-east-2b"]
  app_task_family              = "bia-task"
  container_port               = 3001
  app_task_name                = "bia-task"
  ecs_task_execution_role_name = "bia-task-definition-role"
  bia_load_balancer_name       = "ALB-BIA"
  target_group_name            = "TG-BIA"
  bia_service_name             = "bia-service"
  cidr_blocks_subnets          = ["10.50.10.0/24", "10.50.110.0/24", "10.50.20.0/24", "10.50.220.0/24"]
  environment                  = "lab-test-conectividade"
  cidr_block_vpc               = "10.50.0.0/16"

  #EC2
  #image_id             = "ami-022661f8a4a1b91cf" #amazon linux 2023 
  image_id             = "ami-0f6000d4563f2c95f"
  instance_type        = "t2.micro"
  key_name             = "laboratorio-aws-2024-keys"
  iam_instance_profile = "role-acesso-ssm"

  #ECS Auto Scaling
  max_size              = 2
  min_size              = 1
  desired_capacity      = 1
  asg_health_check_type = "ELB"
  target_group_arns     = []
}
#name = "${var.project}-${var.prefix}"
#tags = {
#    project      = var.project
#    orgunit      = var.org_unit
#    businessunit = var.business_unit
#    costcenter   = var.cost_center
#    appid        = var.appid
#    appname      = var.name
#    desc         = var.desc
#    tier         = var.tier
#    createdby    = var.created_by
#    createdon    = timestamp()
#    env  = var.env
#  }