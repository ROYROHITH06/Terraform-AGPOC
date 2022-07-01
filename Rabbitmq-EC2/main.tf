provider "aws" {
  region = "ap-south-1"
  profile = "default"
 }
resource "aws_instance" "my_instance" {
  count          = 1
  ami            = var.ami
  instance_type  = var.instance_type
  key_name       = var.key_name
  vpc_security_group_ids = [aws_security_group.my_security.id]
  user_data      = <<-EOF
                   #!/bin/bash
                   sudo apt-get update
                   sudo apt-get install wget apt-transport-https -y
                   wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -
                   echo "deb https://dl.bintray.com/rabbitmq-erlang/debian focal erlang-22.x" | sudo tee /etc/apt/sources.list.d/rabbitmq.list
                   sudo apt-get install rabbitmq-server -y --fix-missing
                   sudo rabbitmq-plugins enable rabbitmq_management
                   sudo rabbitmqctl add_user admin Agdemopassword123
                   sudo rabbitmqctl set_user_tags admin administrator
                   EOF
  tags  = {
    Name  = "Agdemmorabbitmq"
  }
 }

