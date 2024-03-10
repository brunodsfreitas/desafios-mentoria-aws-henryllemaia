#Task Definition
variable "td_task_family" {
  type        = string
  description = "Task Family Name"
}
variable "ecr_repo_url" { type = string }
variable "td_task_name" {
  type        = string
  description = "Nome da Task Definition"
  default     = "TD"
}
variable "application_container_port" {
  type        = number
  description = "Porta da Aplicação da Task Definition"
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

#Target Group
variable "target_group_name" {
  type        = string
  description = "Nome do Target Group"
  default     = "TG"
}
variable "vpc_id_for_tg" {
  type        = string
  description = "ID da VPC utilizada no projeto"
  default     = null
}

#Listener
variable "alb_arn_to_listener" {
  type        = string
  description = "ARN do Load Balancer do Projeto"
  default     = null
}

#IAM
variable "ecs_task_execution_role_name" {
  type        = string
  description = "IAM Role para execução da Task Definition"
  default     = null
}

#ECS Service
variable "service_name" {
  type        = string
  description = "Nome do Serviço para rodar no Cluster"
  default     = "servico"
}
variable "autoscaling_group_name" {
  type        = string
  description = "Nome do Autoscaling Group"
  default     = "ASG"
}
variable "autoscaling_group_arn" {
  type        = string
  description = "ARN do Autoscaling Group"
  default     = null
}
variable "cluster_id_for_service" {
  type        = string
  description = "ID do Cluster ECS utilizado no projeto"
  default     = null
}

#Organization
variable "desc_tags" {
  type        = map(string)
  description = "Tags Globais do Projeto"
  default     = null
}