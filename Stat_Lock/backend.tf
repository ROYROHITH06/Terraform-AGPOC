terraform {
  backend "s3" {
    bucket    = "roy-rohith-demo-s3" #The bucket name should be unique
    key       = "default/terraform.tfstate"
    region    = "ap-south-1"
    dynamodb_table = "terraform-state-lock-dynamo"
    encrypt   = "true"
   }
 }

