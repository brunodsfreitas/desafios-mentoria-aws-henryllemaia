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

variable "public_inbound_acl_rules" {
  type        = list(map(string))
  description = "public_inbound_acl_rules"
  default     = null
}

variable "public_outbound_acl_rules" {
  type        = list(map(string))
  description = "public_inbound_acl_rules"
  default     = null
}

variable "private_inbound_acl_rules" {
  type        = list(map(string))
  description = "private_inbound_acl_rules"
  default     = null
}

variable "private_outbound_acl_rules" {
  type        = list(map(string))
  description = "private_outbound_acl_rules"
  default     = null
}



/*
###########################################################################
# Module core_infrastructure
###########################################################################

# Services
variable "ecs_cluster_name" {
  type        = string
  description = "Nome do Cluster ECS"
  default     = "Projeto"
}
variable "load_balancer_name" {
  type        = string
  description = "Nome do Load Balancer"
  default     = "LB"
}


# VPC
variable "cidr_blocks_subnets" {
  type        = list(string)
  description = "Lista de CIDR de Subnets para o projeto"
  default     = null
}
variable "cidr_block_vpc" {
  type        = string
  description = "CIDR da VPC do Projeto"
  default     = null
}
variable "availability_zones" {
  type        = list(string)
  description = "Lista das Zonas de Disponibilidades para o projeto"
  default     = null
}

# EC2
variable "image_id" {
  type        = string
  description = "Image-ID (AMI) que será usada para subir as EC2"
  default     = "ami-0f6000d4563f2c95f" #Amazon Linux With ECS
}
variable "instance_type" {
  type        = string
  description = "Tipo de Instância que será usada para subir EC2"
  default     = "t2.micro"
}
variable "key_name" {
  type        = string
  description = "Chave PEM para uso na autenticação com a EC2"
  default     = null
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM Instance Profile que será atribuida na EC2"
  default     = null
}


###########################################################################
# Module application_qrcode
###########################################################################

variable "td_task_name" {
  type        = string
  description = "Nome da Task Definition"
  default     = "TD"
}
variable "td_task_family" {
  type        = string
  description = "Nome (family) da Task Definition"
  default     = null
}
variable "application_container_port" {
  type        = number
  description = "Porta da Aplicação da Task Definition"
  default     = null
}
variable "service_name" {
  type        = string
  description = "Nome do Serviço para rodar no Cluster"
  default     = "servico"
}
variable "target_group_name" {
  type        = string
  description = "Nome do Target Group"
  default     = "TG"
}
variable "ecs_task_execution_role_name" {
  type        = string
  description = "IAM Role para execução da Task Definition"
  default     = null
}
variable "td_memory" {
  type        = number
  description = "Quantidade em MB de mémoria a ser alocada pela Task Definition"
  default     = 256
}
variable "td_cpu" {
  type        = number
  description = "Quantidade de CPU a ser alocada pela Task Definition"
  default     = 256
}


###########################################################################
# Module application_tosios
###########################################################################

variable "tosios_td_task_name" {
  type        = string
  description = "Nome da Task Definition"
  default     = "TD"
}
variable "tosios_td_task_family" {
  type        = string
  description = "Nome (family) da Task Definition"
  default     = null
}
variable "tosios_application_container_port" {
  type        = number
  description = "Porta da Aplicação da Task Definition"
  default     = null
}
variable "tosios_service_name" {
  type        = string
  description = "Nome do Serviço para rodar no Cluster"
  default     = "servico"
}
variable "tosios_target_group_name" {
  type        = string
  description = "Nome do Target Group"
  default     = "TG"
}
variable "tosios_ecs_task_execution_role_name" {
  type        = string
  description = "IAM Role para execução da Task Definition"
  default     = null
}
variable "tosios_td_memory" {
  type        = number
  description = "Quantidade em MB de mémoria a ser alocada pela Task Definition"
  default     = 256
}
variable "tosios_td_cpu" {
  type        = number
  description = "Quantidade de CPU a ser alocada pela Task Definition"
  default     = 256
}
variable "app_qrcode_target_group_arn" {
  type        = string
  description = "target group"
  default     = null
}
variable "target_group_desafio2_bia_arn" {
  type        = string
  description = "target_group_desafio2_bia_arn"
  default     = null
}



*/


