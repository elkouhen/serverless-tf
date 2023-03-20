output "api_arn" {
  value = aws_api_gateway_rest_api.api.arn
}

output "spec" {
  value = data.template_file.api.template
}