output "db_endpoint" {
  value = aws_db_instance.mysql.address
}

output "db_port" {
  value = aws_db_instance.mysql.port
}

output "db_name" {
  value = aws_db_instance.mysql.db_name
}

output "db_username" {
  value = aws_db_instance.mysql.username
}

output "master_secret_arn" {
  value = aws_db_instance.mysql.master_user_secret[0].secret_arn
}

output "db_security_group_id" {
  value = aws_security_group.mysql.id
}