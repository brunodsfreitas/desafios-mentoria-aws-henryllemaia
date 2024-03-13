#Task Definition
variable "td_task_family" {
  type        = string
  description = "Task Family Name"
}
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

variable "app_qrcode_target_group_arn" {
  type        = string
  description = "target group"
  default     = null
}

variable "app_qrcode_listener_arn" {
  type        = string
  description = "listener"
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

#DNS Record
variable "domain" {
  type        = string
  description = "Zone ID do registro de DNS Route53"
  default     = null
}
variable "alb_name_to_dns_record" {
  type        = string
  description = "Nome do Load Balancer do Projeto"
  default     = null
}
variable "alb_zone_id_to_dns_record" {
  type        = string
  description = "ZoneID do Load Balancer do Projeto"
  default     = null
}
variable "alb_dns_name_to_dns_record" {
  type        = string
  description = "DNS Name do Load Balancer do Projeto"
  default     = null
}

#Organization
variable "desc_tags" {
  type        = map(string)
  description = "Tags Globais do Projeto"
  default     = null
}