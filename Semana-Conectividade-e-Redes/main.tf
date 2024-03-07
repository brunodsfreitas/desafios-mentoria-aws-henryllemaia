terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.39.1"
    }
  }
}

provider "aws" {
  region  = "us-east-2"
  profile = "default"
}

module "ecrRepo" {
    source = "./modules/ecr"
    ecr_repo_name = local.ecr_repo_name
}

module "ecsCluster" {
  source = "./modules/ecs"
  
  lab_cluster_name = local.lab_cluster_name
  availability_zones = local.availability_zones
  app_task_family = local.app_task_family
  ecr_repo_url = module.ecrRepo.repository_url
  container_port = local.container_port
  app_task_name = local.app_task_name
  ecs_task_execution_role_name = local.ecs_task_execution_role_name
  bia_load_balancer_name = local.bia_load_balancer_name
  target_group_name = local.target_group_name
  bia_service_name = local.bia_service_name

}