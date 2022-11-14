output "instance_ip_addr" {
  value = aws_instance.phonebook_instance.private_ip
}
