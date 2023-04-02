output "userpool_arn" {
  value = module.cognito.userpool_arn
}

output "api_arn" {
  value = module.api.api_arn
}

output "helloworld_arn" {
  value = module.helloworld.function_arn
}