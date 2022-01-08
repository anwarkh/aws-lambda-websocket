output "api_base_url" {
  value = aws_apigatewayv2_stage.ProdStage.invoke_url
  description = "The public URl of the API"
}