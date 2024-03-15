output "container_name" {
  description = "Informações Compartilhadas para outros módulos"
  value       = basename(aws_ecs_service.app.task_definition)
}
output "target_group_desafio2_bia_arn" {
  description = "Informações Compartilhadas para outros módulos"
  value       = aws_lb_target_group.desafio2.arn
}

