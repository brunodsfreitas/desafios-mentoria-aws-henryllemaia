output "container_name" {
  description = "Informações Compartilhadas para outros módulos"
  value       = basename(aws_ecs_service.this.task_definition)
}