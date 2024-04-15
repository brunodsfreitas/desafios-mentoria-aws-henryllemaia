###########################################################################
# Global Project Organization
###########################################################################

variable "region" {
  type        = string
  description = "Definição da Região"
  default     = "us-east-2"
}
variable "profile" {
  type        = string
  description = "Definição do AWS Profile"
  default     = "default"
}

variable "desc_tags" {
  type        = map(string)
  description = "Tags Globais do Projeto"
  default     = null
}

variable "domain" {
  type        = string
  description = "Zone ID do registro de DNS Route53"
  default     = null
}

###############
### VPC
###############
variable "vpc_id" {
  type        = string
  description = "VPC ID"
  default     = null
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR Block"
  default     = null
}

variable "private_subnets" {
  type        = list(string)
  description = "Private Subnets CIDR Block"
  default     = null
}

variable "intra_subnets" {
  type        = list(string)
  description = "Intra Subnets CIDR Block"
  default     = null
}

variable "database_subnets" {
  type        = list(string)
  description = "Database Subnets CIDR Block"
  default     = null
}

variable "public_subnets" {
  type        = list(string)
  description = "Public Subnets CIDR Block"
  default     = null
}

variable "subnet_availability_zones" {
  type        = list(string)
  description = "Subnet availability zones"
  default     = null
}


### ec2 2
variable "ec2_2_name" {
  type        = string
  description = "EC2 name"
  default     = null
}
variable "ec2_2_instance_type" {
  type        = string
  description = "EC2 instance_type"
  default     = "t2.micro"
}
variable "ec2_2_key_name" {
  type        = string
  description = "EC2 key_name"
  default     = null
}
variable "ec2_2_iam_instance_profile" {
  type        = string
  description = "EC2 iam_instance_profile"
  default     = null
}
variable "ec2_2_user_data" {
  type        = string
  description = "EC2 user_data"
  default     = null
}
variable "ec2_2_ami" {
  type        = string
  description = "EC2 ami"
  default     = null
}

### ec2 3
variable "ec2_3_name" {
  type        = string
  description = "EC2 name"
  default     = null
}
variable "ec2_3_instance_type" {
  type        = string
  description = "EC2 instance_type"
  default     = "t2.micro"
}
variable "ec2_3_key_name" {
  type        = string
  description = "EC2 key_name"
  default     = null
}
variable "ec2_3_iam_instance_profile" {
  type        = string
  description = "EC2 iam_instance_profile"
  default     = null
}
variable "ec2_3_user_data" {
  type        = string
  description = "EC2 user_data"
  default     = null
}
variable "ec2_3_ami" {
  type        = string
  description = "EC2 ami"
  default     = null
}

### ec2 4
variable "ec2_4_name" {
  type        = string
  description = "EC2 name"
  default     = null
}
variable "ec2_4_instance_type" {
  type        = string
  description = "EC2 instance_type"
  default     = "t2.micro"
}
variable "ec2_4_key_name" {
  type        = string
  description = "EC2 key_name"
  default     = null
}
variable "ec2_4_iam_instance_profile" {
  type        = string
  description = "EC2 iam_instance_profile"
  default     = null
}
variable "ec2_4_user_data" {
  type        = string
  description = "EC2 user_data"
  default     = null
}
variable "ec2_4_ami" {
  type        = string
  description = "EC2 ami"
  default     = null
}

###############
### Security Groups
###############
variable "sg1_name" {
  type        = string
  description = "sg1_name"
  default     = null
}
variable "sg1_description" {
  type        = string
  description = "sg1_description"
  default     = null
}
variable "sg1_ingress_with_cidr_blocks1" {
  type        = list(map(string))
  description = "sg1_ingress_with_cidr_blocks1"
  default     = null
}
variable "sg1_egress_with_cidr_blocks1" {
  type        = list(map(string))
  description = "sg1_egress_with_cidr_blocks1"
  default     = null
}
###############
### tosios
###############
variable "sg2_name" {
  type        = string
  description = "sg2_name"
  default     = null
}
variable "sg2_description" {
  type        = string
  description = "sg2_description"
  default     = null
}
variable "sg2_ingress_with_cidr_blocks1" {
  type        = list(map(string))
  description = "sg2_ingress_with_cidr_blocks1"
  default     = null
}
variable "sg2_egress_with_cidr_blocks1" {
  type        = list(map(string))
  description = "sg2_egress_with_cidr_blocks1"
  default     = null
}
###############
### qr
###############
variable "sg3_name" {
  type        = string
  description = "sg3_name"
  default     = null
}
variable "sg3_description" {
  type        = string
  description = "sg3_description"
  default     = null
}
variable "sg3_ingress_with_cidr_blocks1" {
  type        = list(map(string))
  description = "sg3_ingress_with_cidr_blocks1"
  default     = null
}
variable "sg3_egress_with_cidr_blocks1" {
  type        = list(map(string))
  description = "sg3_egress_with_cidr_blocks1"
  default     = null
}

###############
### prod
###############
variable "sg4_name" {
  type        = string
  description = "sg4_name"
  default     = null
}
variable "sg4_description" {
  type        = string
  description = "sg4_description"
  default     = null
}
variable "sg4_ingress_with_cidr_blocks1" {
  type        = list(map(string))
  description = "sg4_ingress_with_cidr_blocks1"
  default     = null
}
variable "sg4_egress_with_cidr_blocks1" {
  type        = list(map(string))
  description = "sg4_egress_with_cidr_blocks1"
  default     = null
}

###############
### endpoints
###############
variable "sg5_name" {
  type        = string
  description = "sg5_name"
  default     = null
}
variable "sg5_description" {
  type        = string
  description = "sg5_description"
  default     = null
}
variable "sg5_ingress_with_cidr_blocks1" {
  type        = list(map(string))
  description = "sg5_ingress_with_cidr_blocks1"
  default     = null
}
variable "sg5_egress_with_cidr_blocks1" {
  type        = list(map(string))
  description = "sg5_egress_with_cidr_blocks1"
  default     = null
}

###############
### alb
###############
variable "sg6_name" {
  type        = string
  description = "sg6_name"
  default     = null
}
variable "sg6_description" {
  type        = string
  description = "sg6_description"
  default     = null
}
variable "sg6_ingress_with_cidr_blocks1" {
  type        = list(map(string))
  description = "sg6_ingress_with_cidr_blocks1"
  default     = null
}
variable "sg6_egress_with_cidr_blocks1" {
  type        = list(map(string))
  description = "sg6_egress_with_cidr_blocks1"
  default     = null
}
###############
### instance connect endpoint
###############
variable "sg7_name" {
  type        = string
  description = "sg7_name"
  default     = null
}
variable "sg7_description" {
  type        = string
  description = "sg7_description"
  default     = null
}
variable "sg7_ingress_with_cidr_blocks1" {
  type        = list(map(string))
  description = "sg7_ingress_with_cidr_blocks1"
  default     = null
}
variable "sg7_egress_with_cidr_blocks1" {
  type        = list(map(string))
  description = "sg7_egress_with_cidr_blocks1"
  default     = null
}

###############
### ECS
###############
variable "ecs_name" {
  type        = string
  description = "ecs_name"
  default     = "ECS"
}

variable "ecs_iam_role_task_exec" {
  type        = string
  description = "ecs_iam_role_task_exec"
  default     = null
}

variable "ecs_service_1_name" {
  type        = string
  description = "ecs_service_1_name"
  default     = "service1"
}

variable "as_health_check_type" {
  type        = string
  description = "as_health_check_type"
  default     = "EC2"
}

variable "as_min_size" {
  type        = number
  description = "as_min_size"
  default     = 1
}

variable "as_max_size" {
  type        = number
  description = "as_max_size"
  default     = 3
}

variable "as_desired_capacity" {
  type        = number
  description = "as_desired_capacity"
  default     = 2
}

variable "ecr_repository" {
  type        = string
  description = "ecr_repository"
  default     = null
}

variable "eice_ip_range" {
  type        = map(string)
  description = "eice_ip_range"
  default     = null
}

variable "ecs_alb_port" {
  type        = number
  description = "ecs_alb_port"
  default     = null
}
variable "ecs_container_port" {
  type        = number
  description = "ecs_container_port"
  default     = null
}

variable "ecs_asg_key" {
  type        = string
  description = "ecs_asg_key"
  default     = null
}

###############
### RDS
###############
variable "rds_instance_class" {
  type        = string
  description = "rds_instance_class"
  default     = "db.t3.micro"
}
variable "rds_db_name" {
  type        = string
  description = "rds_db_name"
  default     = null
}
variable "rds_username" {
  type        = string
  description = "rds_username"
  default     = null
}
variable "rds_password" {
  type        = string
  description = "rds_password"
  default     = null
  sensitive   = true
}
variable "alb_subdomain_dns_record" {
  type        = string
  description = "alb_subdomain_dns_record"
  default     = null
}