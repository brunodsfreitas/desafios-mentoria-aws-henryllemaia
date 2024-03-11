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

###########################################################################
# Module ecsCluster
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

# Auto Scaling
variable "max_size" {
  type        = number
  description = "Quantidade Máxima de EC2 (Autoscaling Group)"
  default     = 2
}
variable "min_size" {
  type        = number
  description = "Quantidade Mínima de EC2 (Autoscaling Group)"
  default     = 1
}
variable "desired_capacity" {
  type        = number
  description = "Quantidade desejada de EC2 (Autoscaling Group)"
  default     = 1
}
variable "asg_health_check_type" {
  type        = string
  description = "Tipo do HealthCheck (Autoscaling Group)"
  default     = "ELB"
}


###########################################################################
# Module ecrRepo
###########################################################################
variable "ecr_repo_name" {
  type        = string
  description = "Nome do repositório ECR"
  default     = null
}

###########################################################################
# Module TaskDefinition_Application
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
variable "app_config_db_user" {
  type        = string
  description = "Nome do usuário do banco de dados"
  default     = "postgres"
}

variable "app_config_db_pwd" {
  type        = string
  description = "Senha do usuário do banco de dados"
  default     = "postgres"
}

variable "app_config_db_host" {
  type        = string
  description = "Endereço do serviço de banco de dados"
  default     = "postgres"
}
variable "app_config_db_port" {
  type        = number
  description = "Porta do Banco de dados"
  default     = 5432
}


###########################################################################
# Module TaskDefinition_Database
###########################################################################

variable "db_td_task_name" {
  type        = string
  description = "Nome da Task Definition"
  default     = "TD"
}
variable "db_td_task_family" {
  type        = string
  description = "Nome (family) da Task Definition"
  default     = null
}
variable "db_application_container_port" {
  type        = number
  description = "Porta da Aplicação da Task Definition"
  default     = null
}
variable "db_service_name" {
  type        = string
  description = "Nome do Serviço para rodar no Cluster"
  default     = "servico"
}
variable "db_target_group_name" {
  type        = string
  description = "Nome do Target Group"
  default     = "TG"
}
variable "db_ecs_task_execution_role_name" {
  type        = string
  description = "IAM Role para execução da Task Definition"
  default     = null
}
variable "db_td_memory" {
  type        = number
  description = "Quantidade em MB de mémoria a ser alocada pela Task Definition"
  default     = 256
}
variable "db_td_cpu" {
  type        = number
  description = "Quantidade de CPU a ser alocada pela Task Definition"
  default     = 256
}
variable "db_name" {
  type        = string
  description = "Nome do banco de dados"
  default     = "postgres"
}

variable "db_username" {
  type        = string
  description = "Nome do usuário do banco de dados"
  default     = "postgres"
}

variable "db_password" {
  type        = string
  description = "Senha do usuário do banco de dados"
  default     = "postgres"
}