provider "aws" {
# export AWS_ACCESS_KEY_ID = "AKIAXBMESHIKEYJEYBKG"
# export AWS_SECRET_ACCESS_KEY = "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"
# export AWS_DEFAULT_REGION = "eu-central-1"
    access_key = "AKIAXBMESHIKEYJEYBKG"
    secret_key = "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"
    region = "eu-central-1"
}

resource "aws_instance" "phonebook_instance" {
    ami = "ami-070b208e993b59cea"
    instance_type = "t2.micro"
		vpc_security_group_ids = [aws_security_group.phbook_sg.id]
# 		user_data = <<EOF
# #!/bin/bash
# sudo su
# yum update -y
# yum install -y httpd
# systemctl start httpd.service
# systemctl enable httpd.service
# echo -n "xxx" > /var/www/html/index.html
# EOF
    user_data = file("userdata.sh")
	  tags = {
        Name = "Test server for lesson 33"
				Owner = "Serhii Hordiienko"
	  }
}

resource "aws_security_group" "phbook_sg" {
    name = "Test security group for lesson 33"
		description = "HTTP and SSH"

    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
