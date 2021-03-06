variable "ami" {
 default = "ami-005de95e8ff495156"
 }

variable "instance_type" {
  default = "t2.micro"
 }

variable "aws_region" {
  default = "us-east-1"
 }

variable "subnet_cidr" {
 default = "10.180.0.0/24"
}

variable "key_name" {
  description = "key name for the instance"
  default = "newpemkey"
 }

variable "vpc_cidr" {
  default = "10.180.0.0/16"
 }
