#GLOBAL 
region  = "us-east-2"
profile = "default"
domain  = "mudar" #change
###########################################################################
# Global Project Organization
###########################################################################
desc_tags = {
  project      = "SemanaConectividadeAWS"
  orgunit      = "Desafio2"
  businessunit = "Matriz"
  costcenter   = "estudos"
  appid        = "01.01"
  appname      = "MeiosAcessos"
  desc         = "Formas de Acesso"
  environment  = "lab-desafio-conectividade-2"
  createdby    = "BrunoFreitas"
  #createdon                  = timeadd(timestamp(), "-3h")
}


###########################################################################
# Module core_infrastructure
###########################################################################
#VPC
cidr_blocks_subnets = ["10.15.10.0/24", "10.15.110.0/24", "10.15.20.0/24", "10.15.220.0/24"]
cidr_block_vpc      = "10.15.0.0/16"
availability_zones  = ["us-east-2a", "us-east-2b"]
load_balancer_name  = "alb"

#EC2
image_id             = "ami-0f6000d4563f2c95f" #Amazon Linux With ECS
instance_type        = "t2.micro"
key_name             = "mudar" #change
iam_instance_profile = "role-acesso-ssm"

#Services
ecs_cluster_name = "desafio2"

###########################################################################
# Module TaskDefinition_Application
###########################################################################
td_task_name                 = "qrcode"
td_task_family               = "taskdef-qrcode"
application_container_port   = 3000
service_name                 = "service-qrcode"
target_group_name            = "TG-qrcode"
ecs_task_execution_role_name = "qrcode-task-definition-role"
td_cpu                       = 128
td_memory                    = 256


###########################################################################
# Module TaskDefinition_Database
###########################################################################
db_td_task_name                 = "tosios"
db_td_task_family               = "taskdef-tosios"
db_application_container_port   = 3001
db_service_name                 = "service-tosios"
db_target_group_name            = "TG-tosios"
db_ecs_task_execution_role_name = "tosios-task-definition-role"
db_td_cpu                       = 512
db_td_memory                    = 512