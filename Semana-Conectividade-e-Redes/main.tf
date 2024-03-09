module "ecrRepo" {
  source        = "./modules/ecr"
  ecr_repo_name = local.ecr_repo_name
}

module "ecsCluster" {
  source                       = "./modules/ecs"
  lab_cluster_name             = local.lab_cluster_name
  availability_zones           = local.availability_zones
  app_task_family              = local.app_task_family
  ecr_repo_url                 = module.ecrRepo.repository_url
  container_port               = local.container_port
  ecs_task_execution_role_name = local.ecs_task_execution_role_name
  bia_load_balancer_name       = local.bia_load_balancer_name
  target_group_name            = local.target_group_name
  bia_service_name             = local.bia_service_name
  cidr_block_vpc               = local.cidr_block_vpc
  cidr_blocks_subnets          = local.cidr_blocks_subnets
  environment                  = local.environment
  app_task_name                = local.app_task_name
  desc_tags                    = local.desc_tags
  target_group_arns            = local.target_group_arns
  key_name                     = local.key_name
  min_size                     = local.min_size
  max_size                     = local.max_size
  desired_capacity             = local.desired_capacity
  iam_instance_profile         = local.iam_instance_profile
  image_id                     = local.image_id
  instance_type                = local.instance_type
  asg_health_check_type        = local.asg_health_check_type
}