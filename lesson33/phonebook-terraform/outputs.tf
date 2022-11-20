# output "instance_ip_addr" {
#   value = aws_instance.phonebook_instance.public_ip
# }

# output "instance_dns" {
#   value = aws_instance.phonebook_instance.public_dns
# }

output "eip_instance_ip_addr" {
  value = aws_eip.my_eip.public_ip
}

output "eip_instance_dns" {
  value = aws_eip.my_eip.public_dns
}

output "db_server" {
  value = aws_db_instance.database.address
}

output "db_port" {
  value = aws_db_instance.database.port
}

output "db_user" {
  value = var.db_user
}

output "db_pass" {
  value = var.db_pass
}

output "db_name" {
  value = var.db_name
}
