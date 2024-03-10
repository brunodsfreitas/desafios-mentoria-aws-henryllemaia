############################################################################################
# Module
############################################################################################
module "ecrRepo" {
  source        = "./modules/ecr"
  ecr_repo_name = var.ecr_repo_name
}


############################################################################################
# Module
############################################################################################
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
  app_config_db_host           = module.TaskDefinition_Database.container_name
  app_config_db_port           = var.app_config_db_port
  app_config_db_pwd            = var.app_config_db_pwd
  app_config_db_user           = var.app_config_db_user

  # Global Project Organization
  desc_tags = var.desc_tags

  #Module ecsCluster
  ecr_repo_url           = module.ecrRepo.repository_url
  autoscaling_group_arn  = module.ecsCluster.module_info.autoscaling_group_arn
  autoscaling_group_name = module.ecsCluster.module_info.autoscaling_group_name
  vpc_id_for_tg          = module.ecsCluster.module_info.vpc_id
  alb_arn_to_listener    = module.ecsCluster.module_info.alb_arn
  cluster_id_for_service = module.ecsCluster.module_info.cluster_id
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

}