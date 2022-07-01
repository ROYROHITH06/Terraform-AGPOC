provider "aws" {
  alias = "mumbai"
  region = "ap-south-1"
  profile = "default"
 }
provider "aws" {
  alias = "virginia"
  region = "us-east-1"
  profile = "default"
}
resource "aws_instance" "example" {
  ami ="ami-04505e74c0741db8d"
  instance_type ="t2.micro"
  provider = aws.virginia
}
variable "user_name" {
 description = "create iam user with the name"
 default = ["rohith", "arjun", "raju"]
}
resource "aws_iam_user" "example" {
  count = length(var.user_name)
  name = var.user_name[count.index]
}
