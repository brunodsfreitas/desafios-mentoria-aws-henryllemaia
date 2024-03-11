#GLOBAL 
region  = "us-east-2"
profile = "default"
domain  = "seu-id" #change
###########################################################################
# Global Project Organization
###########################################################################
desc_tags = {
  project      = "SemanaConectividadeAWS"
  orgunit      = "Desafio1"
  businessunit = "Matriz"
  costcenter   = "estudos"
  appid        = "01.01"
  appname      = "ClusterBia"
  desc         = "ECS com EC2 com NatGateway"
  environment  = "lab-desafio-conectividade-1"
  createdby    = "BrunoFreitas"
  #createdon                  = timeadd(timestamp(), "-3h")
}


###########################################################################
# Module ecsCluster
###########################################################################
#VPC
cidr_blocks_subnets = ["10.50.10.0/24", "10.50.110.0/24", "10.50.20.0/24", "10.50.220.0/24"]
cidr_block_vpc      = "10.50.0.0/16"
availability_zones  = ["us-east-2a", "us-east-2b"]

#EC2
image_id             = "ami-0f6000d4563f2c95f" #Amazon Linux With ECS
instance_type        = "t2.micro"
key_name             = "sua-key"         #change
iam_instance_profile = "sua-role-acesso" #change

#Autoscaling Group
max_size              = 2
min_size              = 1
desired_capacity      = 1
asg_health_check_type = "ELB"

#Services
ecs_cluster_name   = "lab-bia-cluster"
load_balancer_name = "ALB-BIA"


###########################################################################
# Module ecrRepo
###########################################################################
ecr_repo_name = "lab_semana_conectividade"


###########################################################################
# Module TaskDefinition_Application
###########################################################################
td_task_name                 = "bia-task"
td_task_family               = "bia-task"
application_container_port   = 8080
service_name                 = "bia-service"
target_group_name            = "TG-BIA"
ecs_task_execution_role_name = "bia-task-definition-role"
td_cpu                       = 256
td_memory                    = 256
app_config_db_port           = 5432
app_config_db_pwd            = "postgres"
app_config_db_user           = "postgres"


###########################################################################
# Module TaskDefinition_Database
###########################################################################
db_td_task_name                 = "db-task"
db_td_task_family               = "db-task"
db_application_container_port   = 5432
db_service_name                 = "db-service"
db_target_group_name            = "TG-db"
db_ecs_task_execution_role_name = "db-task-definition-role"
db_td_cpu                       = 256
db_td_memory                    = 512
db_name                         = "bia"
db_password                     = "postgres"
db_username                     = "postgres"