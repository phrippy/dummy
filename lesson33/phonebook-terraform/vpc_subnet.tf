resource "aws_vpc" "my_vpc" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "lesson33"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "192.168.8.0/24"
  # availability_zone = "eu-central-1a"
  map_public_ip_on_launch = true
  depends_on              = [aws_internet_gateway.gw]

  tags = {
    Name = "lesson33"
  }
}

resource "aws_eip" "my_eip" {
  vpc                       = true
  network_interface         = aws_network_interface.my_network_interface.id
  instance                  = aws_instance.phonebook_instance.id
  associate_with_private_ip = "192.168.8.8"
  depends_on                = [aws_internet_gateway.gw, aws_network_interface.my_network_interface]
}

resource "aws_network_interface" "my_network_interface" {
  subnet_id       = aws_subnet.my_subnet.id
  private_ips     = ["192.168.8.8"]
  security_groups = [aws_security_group.phbook_sg.id]

  tags = {
    Name : "lesson33"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "lesson33"
  }
}

resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "lesson33"
  }
}

resource "aws_security_group" "phbook_sg" {
  name        = "Test security group for lesson 33"
  description = "HTTP and SSH"
  vpc_id      = aws_vpc.my_vpc.id

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

  # Allow ping
  ingress {
    description = "PING"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all ICMP
  # ingress {
  #   from_port   = -1
  #   to_port     = -1
  #   protocol    = "icmp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

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
