variable "availability_zones" {
  description = "us-east-2 azs"
  type        = list(string)
}

variable "ecr_repo_url" {
  description = "ecr url"
  type        = string
}

variable "bia_service_name" { type = string }
variable "target_group_name" { type = string }
variable "bia_load_balancer_name" { type = string }
variable "ecs_task_execution_role_name" { type = string }
variable "app_task_family" { type = string }
variable "environment" { type = string }
variable "lab_cluster_name" { type = string }
variable "container_port" { type = string }
variable "cidr_blocks_subnets" { type = list(string) }
variable "cidr_block_vpc" { type = string }
variable "app_task_name" { type = string }
variable "desc_tags" {}
variable "image_id" {}
variable "instance_type" {}
variable "key_name" {}
variable "iam_instance_profile" {}

# Auto Scaling
variable "max_size" {}
variable "min_size" {}
variable "desired_capacity" {}
variable "asg_health_check_type" {}
variable "target_group_arns" {}



