provider "aws" {
  region = "us-east-1"
  profile = "default"
 }

#Create a VPC
#resource "aws_vpc" "my_vpc" {
#  cidr_block           = var.vpc_cidr
#  enable_dns_hostnames = true

# tags = {
#  name = "MY-VPC-POC-DMA01"
# }
#}

#Get a list of available zone in current region

data "aws_availability_zones" "all" {}

#Create Public subnet on the first available zone

resource "aws_subnet" "public_ap_south_1c" {
  vpc_id            = "vpc-00cc4a2a6875a2349"
  cidr_block        = var.subnet02_cidr
  availability_zone = data.aws_availability_zones.all.names[0]

 tags  = {
  name = "MY-AG-POC-PUBLIC-SUBNET02"
 }
}

#Create an IGW for your new VPC
#resource "aws_internet_gateway" "my_vpc_igw" {
#  vpc_id     = aws_vpc.my_vpc.id

# tags = {
#  name  = "MY-IGW-AG-POC-DMA01"
# }
#}

#Create an RouteTable for your VPC
#resource "aws_route_table" "my_vpc_public" {
# vpc_id  = aws_vpc.my_vpc.id

# route  {
#   cidr_block  = "0.0.0.0/0"
#   gateway_id  = aws_internet_gateway.my_vpc_igw.id
#  }

# tags = {
#  name = "MY-DEMO-RT-POC-DMA01"
# }
#}

# Associate the Routetable to the Subnet
resource "aws_route_table_association" "my_vpc_ap_east_1a_public" {
 subnet_id  = aws_subnet.public_ap_south_1c.id
 route_table_id = "rtb-09a5d3c7ecc6e3e26"
}

resource "aws_instance" "my_instance" {
  count          = 1
  ami            = var.ami
  instance_type  = var.instance_type
  key_name       = var.key_name
  vpc_security_group_ids = ["sg-0135b7a11cc4f47ac"]
  subnet_id      = aws_subnet.public_ap_south_1c.id
  associate_public_ip_address = true
  availability_zone = data.aws_availability_zones.all.names[0]
#  user_data      = "${file("install_maven.sh")}"

  root_block_device {
        delete_on_termination = "true"
        volume_type = "gp2"
        volume_size = "${var.volume_size}"
    }

  user_data      = <<-EOF
                   #!/bin/bash
                   sudo apt update
                   sudo apt -y install maven
                   sudo apt -y install default-jdk
                   wget https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz -P /tmp
                   sudo tar xf /tmp/apache-maven-*.tar.gz -C /opt
                   sudo ln -s /opt/apache-maven-3.8.6 /opt/maven
                   export JAVA_HOME=/usr/lib/jvm/default-java
                   export M2_HOME=/opt/maven
                   export MAVEN_HOME=/opt/maven
                   sudo apt update
                   sudo apt -y install openjdk-8-jdk
                   sudo apt -y install openjdk-11-jdk
                   wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
                   sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
                   sudo apt-get -y update
                   sudo apt -y install jenkins
                   sudo ufw allow 8080
                   sudo apt-get -y update
                   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                   curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
                   echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
                   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
		   curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl
                   chmod +x ./kubectl
                   sudo mv ./kubectl /usr/local/bin/kubectl
                   sudo apt-get -y update
                   sudo apt -y install awscli
                   sudo apt-get -y update
                   sudo apt-get -y install docker.io
		   sudo apt -y install docker-compose
                   sudo systemctl enable --now docker
		   sudo chmod 666 /var/run/docker.sock
                   sudo apt-get update
                   curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
                   sudo mv /tmp/eksctl /usr/local/bin
                   eksctl version				   
                   EOF

  tags  = {
   Name  = "AG-POC-DMA-0${count.index + 1}"
  }
 }


