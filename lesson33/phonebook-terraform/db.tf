resource "aws_db_instance" "database" {
  allocated_storage      = 10
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "8.0.31"
  instance_class         = "db.t3.micro"
  username               = "foo"
  password               = "foobarbaz"
  parameter_group_name   = aws_db_parameter_group.default.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.phbook_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.my_db_subnet_group.name
}

# data "aws_db_subnet_group" "database" {
#   name = "phonebook-database-subnet-group"
# }

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name        = "rdsmain-private"
  description = "Private subnets for RDS instance"
  subnet_ids  = ["${aws_subnet.my_subnet.id}", "${aws_subnet.my_subnet1.id}"]
}

resource "aws_db_parameter_group" "default" {
  name   = "rds-my"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

# #provision the database
# resource "aws_db_instance" "database" {
#   identifier             = "database"
#   instance_class         = var.db_instance_type
#   allocated_storage      = var.db_size
#   engine                 = "mysql"
#   multi_az               =  false
#   name                   = "Database "
#   password               = var.rds_password
#   username               = var.rds_user
#   engine_version         = "5.7.00"
#   skip_final_snapshot    = true
#   db_subnet_group_name   = aws_db_subnet_group.rdssubnet.name
#   vpc_security_group_ids = [aws_security_group.rds.id]
# }

# resource "aws_subnet" "rds_subnet" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.1.0/24"
#   availability_zone = "us-east-1a"
# }

# resource "aws_subnet" "rds_subnet1" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.2.0/24"
#   availability_zone = "us-east-1b"
