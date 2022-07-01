variable "ami" {
 default = "ami-0851b76e8b1bce90b"
 }

variable "instance_type" {
  default = "t2.micro"
 }

variable "aws_region" {
  default = "ap-south-1"
 }

variable "key_name" {
  description = "key name for the instance"
  default = "newpemkey"
 }

