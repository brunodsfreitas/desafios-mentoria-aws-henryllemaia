output "container_name" {
  description = "Informações Compartilhadas para outros módulos"
  value       = basename(aws_ecs_service.app.task_definition)
}

output "app_qrcode_target_group_arn" {
  description = "Informações Compartilhadas para outros módulos"
  value       = aws_lb_target_group.this.arn
}

output "app_qrcode_listener_arn" {
  description = "Informações Compartilhadas para outros módulos"
  value       = aws_lb_listener.listener80.arn
}

