output "instance_ip_addr" {
  value = aws_instance.phonebook_instance.public_ip
}

output "instance_dns" {
  value = aws_instance.phonebook_instance.public_dns
}
