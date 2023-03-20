terraform {
  required_providers {
    aws = {
     
      source  = "hashicorp/aws"
      version = "~> 4.59.0"
    }
  }

  backend "s3" {
    bucket  = "melkouhen-tfstate"
    key     = "state/terraform.tfstate"
    region  = "eu-west-3"
    encrypt = true
  }
}


module "helloworld" {
  source = "../modules/helloworld"
}