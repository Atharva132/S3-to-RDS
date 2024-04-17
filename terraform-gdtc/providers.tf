provider "aws" {
  region = var.REGION
}

terraform {
  backend "s3" {
    bucket         	   = "backend-tf-gdtc"
    key              	   = "state/terraform.tfstate"
    region         	   = "us-east-1"
    encrypt        	   = true
  }
}