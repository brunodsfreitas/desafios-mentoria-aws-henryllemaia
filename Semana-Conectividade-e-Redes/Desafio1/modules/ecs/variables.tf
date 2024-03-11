#################################################################
# Cluster
#################################################################
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
#################################################################
# VPC
#################################################################
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

#################################################################
# Launch Template
#################################################################
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
#################################################################
# Application Load Balancer
#################################################################
variable "lb_type" {
  type        = string
  description = "Tipo do Load Balancer"
  default     = "application"
}

#################################################################
# Auto Scaling
#################################################################
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
variable "asg_health_check_grace_period" {
  type        = number
  description = "Tempo em Segundos para validação de health check"
  default     = 60
}


#################################################################
# Organization
#################################################################
variable "desc_tags" { type = map(string) }
