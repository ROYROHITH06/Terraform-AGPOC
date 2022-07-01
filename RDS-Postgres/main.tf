terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.47.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}

#Get a list of available zone in current region

data "aws_availability_zones" "all" {}

resource "aws_subnet" "mysubnet01" {
  vpc_id = "vpc-00cc4a2a6875a2349"
  cidr_block = "10.180.1.0/24"
  availability_zone = data.aws_availability_zones.all.names[1]
 }

resource "aws_route_table_association" "intranet" {
   subnet_id = "${aws_subnet.mysubnet01.id}"
   route_table_id = "rtb-09a5d3c7ecc6e3e26"
}

resource "aws_subnet" "mysubnet02" {
  vpc_id = "vpc-00cc4a2a6875a2349"
  cidr_block = "10.180.2.0/24"
  availability_zone = data.aws_availability_zones.all.names[0]
 }

resource "aws_route_table_association" "intranet1" {
   subnet_id = "${aws_subnet.mysubnet02.id}"
   route_table_id = "rtb-09a5d3c7ecc6e3e26"
}


resource "aws_db_subnet_group" "db_subnet" {
  name = "mysubnet01"
  subnet_ids = ["${aws_subnet.mysubnet01.id}", "${aws_subnet.mysubnet02.id}"]
}

resource "aws_db_instance" "default01" {
  allocated_storage    = 20
  engine               = "postgres"
  identifier           = "agpoc-db01"
  engine_version       = "13"
  instance_class       = "db.t4g.micro"
  name                 = "demousername1"
  username             = "demouser2"
  password             = "DDGdemopassword_123"
  skip_final_snapshot  = true
  publicly_accessible  = true
  multi_az             = false
  db_subnet_group_name = "${aws_db_subnet_group.db_subnet.name}"
 # db_subnet_group_name = var.subnet_group
 # parameter_group_name = var.parameter_group
# vpc_security_group_ids   = ["${aws_security_group.mydb2.id}"]
  vpc_security_group_ids   = [aws_security_group.mydb2.id]


# Local-exec provisioner

provisioner "local-exec" {
   command  = "echo ${aws_db_instance.default01.endpoint}/${aws_db_instance.default01.name} >> endpoint.txt"
#  command =  "sed '3ispring.datasource.url=jdbc:postgresql://${aws_db_instance.default01.endpoint}/${aws_db_instance.default01.name}' endpoint.txt" > endpoint.txt.tmp && "cp endpoint.txt.tmp endpoint.txt"
 }
}

