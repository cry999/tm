output "host" {
  value = aws_db_instance.mariadb.address
}

output "port" {
  value = aws_db_instance.mariadb.port
}
