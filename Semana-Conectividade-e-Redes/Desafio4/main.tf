############################################################################################
# Module
############################################################################################


module "vpc" { #https://github.com/terraform-aws-modules/terraform-aws-vpc
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.desc_tags.project}-vpc"
  cidr = var.vpc_cidr_block

  azs             = var.subnet_availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  intra_subnets   = var.intra_subnets

  default_vpc_enable_dns_support = true
  default_vpc_enable_dns_hostnames = true
  enable_nat_gateway                                         = true
  enable_vpn_gateway                                         = true
  single_nat_gateway                                         = false
  one_nat_gateway_per_az                                     = true
  public_dedicated_network_acl                               = true
  private_dedicated_network_acl                              = true
  intra_subnet_enable_resource_name_dns_a_record_on_launch   = true
  public_subnet_enable_resource_name_dns_a_record_on_launch  = true
  private_subnet_enable_resource_name_dns_a_record_on_launch = true

  public_inbound_acl_rules = var.public_inbound_acl_rules
  public_outbound_acl_rules = var.public_outbound_acl_rules
  public_acl_tags = var.desc_tags
  private_inbound_acl_rules = var.private_inbound_acl_rules
  private_outbound_acl_rules = var.private_outbound_acl_rules
  private_acl_tags = var.desc_tags
  tags = var.desc_tags
}





/*
module "vpc_1" { #https://github.com/terraform-aws-modules/terraform-aws-vpc
  source = "./modules/networking/vpc"
  desc_tags = var.desc_tags
  #VPC
  vpc_cidr_block = var.vpc_cidr_block
  vpc_enable_dns_support = var.vpc_enable_dns_support
  vpc_enable_dns_hostnames = var.vpc_enable_dns_hostnames
  #Subnets
  subnet_cidr_blocks = var.subnet_cidr_blocks
  subnet_names = var.subnet_names
  subnet_availability_zones = var.subnet_availability_zones
  subnet_map_public_ip_on_launch = var.subnet_map_public_ip_on_launch
  subnet_enable_resource_name_dns_a_record_on_launch = var.subnet_enable_resource_name_dns_a_record_on_launch
}





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
  target_group_desafio2_bia_arn  = module.application_tosios.target_group_desafio2_bia_arn

  depends_on = [module.core_infrastructure]
}

############################################################################################
# Module
############################################################################################
module "application_tosios" {
  source = "./modules/application_tosios"

  td_task_name               = var.tosios_td_task_name
  td_task_family             = var.tosios_td_task_family
  application_container_port = var.tosios_application_container_port
  target_group_name          = var.tosios_target_group_name
  service_name               = var.tosios_service_name
  td_cpu                     = var.tosios_td_cpu
  td_memory                  = var.tosios_td_memory

  # Global Project Organization
  desc_tags = var.desc_tags

  #Module core_infrastructure
  autoscaling_group_name      = module.core_infrastructure.module_info.autoscaling_group_name
  vpc_id_for_tg               = module.core_infrastructure.module_info.vpc_id
  alb_arn_to_listener         = module.core_infrastructure.module_info.alb_arn
  cluster_id_for_service      = module.core_infrastructure.module_info.cluster_id
  alb_dns_name_to_dns_record  = module.core_infrastructure.module_info.alb_dns_name
  app_bia_instance_id         = module.core_infrastructure.module_info.app_bia_instance_id
  domain                      = var.domain
  app_qrcode_target_group_arn = module.application_qrcode.app_qrcode_target_group_arn
  app_qrcode_listener_arn     = module.application_qrcode.app_qrcode_listener_arn
  bastion_host_instance_public_ip = module.core_infrastructure.module_info.bastion_host_instance_public_ip

  depends_on = [module.core_infrastructure]
}
*/