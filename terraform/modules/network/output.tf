output "target_group_arn" {
  value = aws_lb_target_group.server.arn
}

output "prv_subnet_id_1" {
  value = aws_subnet.prv1.id
}

output "prv_subnet_id_2" {
  value = aws_subnet.prv2.id
}

output "db_sg" {
  value = aws_security_group.db.id
}

output "prv_sg" {
  value = aws_security_group.prv.id
}

output "service_sg" {
  value = aws_security_group.ecs_task.id
}
