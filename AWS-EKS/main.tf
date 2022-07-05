provider "aws" {
  region = "us-east-1"
  profile = "default"
 }

# Creating IAM user Roll for eks-cluster creation

resource "aws_iam_role" "eks-cluster-agcp" {
  name = "AGPOC-EKS-CLUSTER-TERRAFORM"
  assume_role_policy = <<POLICY
{
 "Version": "2012-10-17",
 "Statement": [
   {
   "Effect": "Allow",
   "Principal": {
    "Service": "eks.amazonaws.com"
   },
   "Action": "sts:AssumeRole"
   }
  ]
 }
POLICY
}

# Attaching the EKS-Cluster policies to the AGPOC-EKS-CLUSTER-TERRAFORM role.

resource "aws_iam_role_policy_attachment" "EKS-clusterpolicy-master" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks-cluster-agcp.name}"
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks-cluster-agcp.name}"
}

# Security group for network traffic to and from AWS EKS Cluster.

resource "aws_security_group" "eks-cluster" {
  name        = "AGPOC-SG-eks-cluster"
  vpc_id      = "vpc-00cc4a2a6875a2349"

# Egress allows Outbound traffic from the EKS cluster to the  Internet

  egress {                   # Outbound Rule
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
# Ingress allows Inbound traffic to EKS cluster from the  Internet

  ingress {                  # Inbound Rule
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

#Get a list of available zone in current region

data "aws_availability_zones" "available" {}

#Create Subnet for Cluster

resource "aws_subnet" "demo" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.180.${count.index+4}.0/24"
  vpc_id            = "vpc-00cc4a2a6875a2349"

  tags = {
    name = "MY-AG-POC-PUBLIC-SUBNETs"
 }

resource "aws_route_table_association" "demo" {
  count = 2

  subnet_id      = aws_subnet.demo.*.id[count.index]
  route_table_id = "rtb-00a4d1a8a4666325d"
}

data "aws_availability_zones" "all_zones" {}

#Create Subnet for Node

resource "aws_subnet" "demonode" {
  count = 2

  availability_zone = data.aws_availability_zones.all_zones.names[count.index]
  cidr_block        = "10.180.${count.index+6}.0/24"
  vpc_id            = "vpc-00cc4a2a6875a2349"
  map_public_ip_on_launch = true

  tags = {
    name = "MY-AG-POC-PUBLIC-SUBNET-node"
 }
}

resource "aws_route_table_association" "demonode" {
  count = 2

  subnet_id      = aws_subnet.demonode.*.id[count.index]
  route_table_id = "rtb-00a4d1a8a4666325d"
}


# Creating the EKS cluster #

resource "aws_eks_cluster" "eks_cluster" {
  name     = "AGPOC-EKS-CLUSTER-TERRAFORM"
  role_arn =  "${aws_iam_role.eks-cluster-agcp.arn}"
  version  = "1.21"

# Adding VPC Configuration

  vpc_config {
   security_group_ids = ["${aws_security_group.eks-cluster.id}"]
 #  subnet_ids         = ["aws_subnet.my_subnets01_eks.id", "aws_subnet.my_subnets02_eks.id"]
   subnet_ids         = aws_subnet.demo[*].id
 }

 depends_on = [
    "aws_iam_role_policy_attachment.EKS-clusterpolicy-master",
    "aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy",
   ]
}

# Creating IAM role for EKS nodes to work with other AWS Services.


resource "aws_iam_role" "eks_nodes" {
  name = "eks-node-group"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Attaching the Policies to Node.

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

# Create EKS cluster node group

resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "node_group1"
  node_role_arn   = aws_iam_role.eks_nodes.arn
 #subnet_ids      = ["{aws_subnet.my_subnets02_eks.id}", "{aws_subnet.my_subnets04_eks.id}"]
 #subnet_ids     = ["{aws_subnet.demo01.id}", "{aws_subnet.demo02.id}"]
  subnet_ids      = aws_subnet.demonode[*].id


  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
 }

  ami_type       = "AL2_x86_64"
  instance_types = ["t3.micro"]
  capacity_type  = "ON_DEMAND"
  disk_size      = 50

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
 }

output "available_zones" {
  value = data.aws_availability_zones.available.names
 }

