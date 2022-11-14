provider "aws" {
  # Obviously, this keys are invalid 🤓
  # export AWS_ACCESS_KEY_ID = "AKIAXBMESHIKJH2WHGMC"
  # export AWS_SECRET_ACCESS_KEY = "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"
  # export AWS_DEFAULT_REGION = "eu-central-1"
  # access_key = "AKIAXBMESHIKJH2WHGMC"
  # secret_key = "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"
  region = "eu-central-1"
}

resource "aws_instance" "phonebook_instance" {
  ami           = "ami-070b208e993b59cea"
  instance_type = "t2.micro"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.my_network_interface.id
  }

  lifecycle {
    # prevent_destroy = true
    # create_before_destroy = true
  }

  depends_on = [aws_internet_gateway.gw]
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

  key_name = "my_ssh_key"
}

