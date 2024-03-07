locals {
    ecr_repo_name = "lab_semana_conectividade"

    lab_cluster_name = "lab_bia_cluster"
    availability_zones = ["us-east-2a", "us-east-2b"]
    app_task_family = "bia-task"
    container_port = 3001
    app_task_name = "bia_task"
    ecs_task_execution_role_name = "bia-task-definition-role"
    bia_load_balancer_name = "ALB_BIA"
    target_group_name = "TG-BIA"
    bia_service_name = "bia-service"
}