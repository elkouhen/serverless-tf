module "helloworld" {
  source      = "../modules/lambda/"
  env         = var.env
  module_name = "helloworld"
}

module "cognito" {
  source = "../modules/cognito/"
  env    = var.env
}

module "api" {
  source         = "../modules/api/"
  env            = var.env
  helloworld_arn = module.helloworld.function_arn
  userpool_arn   = module.cognito.userpool_arn
}

module "gui" {
  source      = "../modules/gui/"
  env         = var.env
  hosted_zone = "sbx.aws.ippon.fr"
  domain_name = "helloworld-${var.env}"
}
