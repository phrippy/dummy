provider "aws" {
  # Obviously, this keys are invalid 🤓
  # export AWS_ACCESS_KEY_ID = "AKIAXBMESHIKJH2WHGMC"
  # export AWS_SECRET_ACCESS_KEY = "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"
  # export AWS_DEFAULT_REGION = "eu-central-1"
  # access_key = "AKIAXBMESHIKJH2WHGMC"
  # secret_key = "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"
  region = "eu-central-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "lesson33"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "192.168.8.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "lesson33"
  }
}

resource "aws_instance" "phonebook_instance" {
  ami                    = "ami-070b208e993b59cea"
  instance_type          = "t2.micro"
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
    Name  = "Test server for lesson 33"
    Owner = "Serhii Hordiienko"
  }
  associate_public_ip_address = true
  key_name                    = "my_ssh_key"
}

resource "aws_security_group" "phbook_sg" {
  name        = "Test security group for lesson 33"
  description = "HTTP and SSH"

  dynamic "ingress" {
    for_each = [["80", "HTTP"], ["22", "SSH"]]
    content {
      description = ingress.value[1]
      from_port   = ingress.value[0]
      to_port     = ingress.value[0]
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # ingress {
  #   description = "HTTP"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  # ingress {
  #   description = "SSH"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_key_pair" "my_keypair" {
  key_name   = "my_ssh_key"
  public_key = file("~/.ssh/id_rsa.pub")
}
