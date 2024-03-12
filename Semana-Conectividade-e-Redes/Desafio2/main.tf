############################################################################################
# Module
############################################################################################
module "core_infrastructure" {
  source = "./modules/core_infrastructure"

  ecs_cluster_name   = var.ecs_cluster_name
  load_balancer_name = var.load_balancer_name

  #VPC
  availability_zones  = var.availability_zones
  cidr_block_vpc      = var.cidr_block_vpc
  cidr_blocks_subnets = var.cidr_blocks_subnets

  #EC2
  key_name             = var.key_name
  image_id             = var.image_id
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile

  # Global Project Organization
  desc_tags = var.desc_tags
}

############################################################################################
# Module
############################################################################################

module "application_qrcode" {
  source = "./modules/application_qrcode"

  td_task_name               = var.td_task_name
  td_task_family             = var.td_task_family
  application_container_port = var.application_container_port
  target_group_name          = var.target_group_name
  service_name               = var.service_name
  td_cpu                     = var.td_cpu
  td_memory                  = var.td_memory

  # Global Project Organization
  desc_tags = var.desc_tags

  #Module core_infrastructure
  autoscaling_group_name     = module.core_infrastructure.module_info.autoscaling_group_name
  vpc_id_for_tg              = module.core_infrastructure.module_info.vpc_id
  alb_arn_to_listener        = module.core_infrastructure.module_info.alb_arn
  cluster_id_for_service     = module.core_infrastructure.module_info.cluster_id
  alb_dns_name_to_dns_record = module.core_infrastructure.module_info.alb_dns_name
  domain                     = var.domain

  depends_on = [module.core_infrastructure]
}
/*
############################################################################################
# Module
############################################################################################
module "dns_routes" {
  source        = "./modules/ecr"
  ecr_repo_name = var.ecr_repo_name
}
############################################################################################
# Module
############################################################################################
module "outbound_routes" {
  source        = "./modules/ecr"
  ecr_repo_name = var.ecr_repo_name
}
############################################################################################
# Module
############################################################################################
module "application_qrcode" {
  source        = "./modules/ecr"
  ecr_repo_name = var.ecr_repo_name
}
############################################################################################
# Module
############################################################################################
module "application_tosios" {
  source        = "./modules/ecr"
  ecr_repo_name = var.ecr_repo_name
}








module "ecsCluster" {
  source = "./modules/ecs"

  ecs_cluster_name   = var.ecs_cluster_name
  load_balancer_name = var.load_balancer_name

  #VPC
  availability_zones  = var.availability_zones
  cidr_block_vpc      = var.cidr_block_vpc
  cidr_blocks_subnets = var.cidr_blocks_subnets

  #EC2
  key_name             = var.key_name
  image_id             = var.image_id
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile

  #Autoscaling Group
  min_size              = var.min_size
  max_size              = var.max_size
  desired_capacity      = var.desired_capacity
  asg_health_check_type = var.asg_health_check_type

  # Global Project Organization
  desc_tags = var.desc_tags
}


############################################################################################
# Module
############################################################################################
module "TaskDefinition_Application" {
  source = "./modules/taskdefinition_app"

  td_task_name                 = var.td_task_name
  td_task_family               = var.td_task_family
  application_container_port   = var.application_container_port
  target_group_name            = var.target_group_name
  service_name                 = var.service_name
  ecs_task_execution_role_name = var.ecs_task_execution_role_name
  td_cpu                       = var.td_cpu
  td_memory                    = var.td_memory
  app_config_db_host           = var.app_config_db_host
  app_config_db_port           = var.app_config_db_port
  app_config_db_pwd            = var.app_config_db_pwd
  app_config_db_user           = var.app_config_db_user
  domain                       = var.domain

  # Global Project Organization
  desc_tags = var.desc_tags

  #Module ecsCluster
  ecr_repo_url               = module.ecrRepo.repository_url
  autoscaling_group_arn      = module.ecsCluster.module_info.autoscaling_group_arn
  autoscaling_group_name     = module.ecsCluster.module_info.autoscaling_group_name
  vpc_id_for_tg              = module.ecsCluster.module_info.vpc_id
  alb_arn_to_listener        = module.ecsCluster.module_info.alb_arn
  cluster_id_for_service     = module.ecsCluster.module_info.cluster_id
  alb_dns_name_to_dns_record = module.ecsCluster.module_info.alb_dns_name

  depends_on = [module.ecsCluster]
}

############################################################################################
# Module
############################################################################################
module "TaskDefinition_Database" {
  source = "./modules/taskdefinition_db"

  td_task_name                  = var.db_td_task_name
  td_task_family                = var.db_td_task_family
  db_application_container_port = var.db_application_container_port
  target_group_name             = var.db_target_group_name
  service_name                  = var.db_service_name
  ecs_task_execution_role_name  = var.db_ecs_task_execution_role_name
  td_cpu                        = var.db_td_cpu
  td_memory                     = var.db_td_memory
  db_name                       = var.db_name
  db_password                   = var.db_password
  db_username                   = var.db_username

  # Global Project Organization
  desc_tags = var.desc_tags

  #Module ecsCluster
  ecr_repo_url           = "postgres:16.1"
  autoscaling_group_arn  = module.ecsCluster.module_info.autoscaling_group_arn
  autoscaling_group_name = module.ecsCluster.module_info.autoscaling_group_name
  vpc_id_for_tg          = module.ecsCluster.module_info.vpc_id
  alb_arn_to_listener    = module.ecsCluster.module_info.alb_arn
  cluster_id_for_service = module.ecsCluster.module_info.cluster_id

  depends_on = [module.ecsCluster]
}*/