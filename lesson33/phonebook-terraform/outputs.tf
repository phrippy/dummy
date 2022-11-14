output "instance_ip_addr" {
  value = aws_instance.phonebook_instance.public_ip
}

output "instance_dns" {
  value = aws_instance.phonebook_instance.public_dns
}

output "eip_instance_ip_addr" {
  value = aws_eip.my_eip.public_ip
}

output "eip_instance_dns" {
  value = aws_eip.my_eip.public_dns
}
