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
  source = "../modules/helloworld/"
  env    = "dev"
}

module "cognito" {
  source = "../modules/cognito/"
  env    = "dev"
}

module "api" {
  source         = "../modules/api/"
  env            = "dev"
  helloworld_arn = module.helloworld.function_arn
  userpool_arn   = module.cognito.userpool_arn
}

module "gui" {
  source = "../modules/gui/"
  env    = "dev"
}

output "userpool_arn" {
  value = module.cognito.userpool_arn
}

output "api_arn" {
  value = module.api.api_arn
}

output "helloworld_arn" {
  value = module.helloworld.function_arn
}
