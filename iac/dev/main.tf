terraform {

  required_version = ">= 1.0" 

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.59.0"
    }

    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.3.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.1"
    }

    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }

  }

  backend "s3" {
    bucket  = "melkouhen-tfstate"
    key     = "state/terraform.tfstate"
    region  = "eu-west-3"
    encrypt = true
  }
}

module "app" {
  source      = "../app/"
  env         = "dev"
  hosted_zone = "sbx.aws.ippon.fr"
  domain_name = "hellworld-dev"
}
