# HTTP Gateway
resource "aws_apigatewayv2_api" "aws-websocket-example-apg" {
  name                       = "example-websocket-api"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}


#
# WebSocket API resources.
#
resource "aws_apigatewayv2_deployment" "Deployment" {
  api_id = aws_apigatewayv2_api.aws-websocket-example-apg.id

  depends_on = [
    aws_apigatewayv2_route.ConnectRoute,
    aws_apigatewayv2_route.DisconnectRoute,
    aws_apigatewayv2_route.DefaultRoute,
  ]
}

resource "aws_apigatewayv2_stage" "ProdStage" {
  api_id        = aws_apigatewayv2_api.aws-websocket-example-apg.id
  name          = "Prod"
  description   = "Prod Stage"
  deployment_id = aws_apigatewayv2_deployment.Deployment.id
}

###########
# OnConnect
###########
resource "aws_apigatewayv2_integration" "ConnectIntegration" {
  api_id             = aws_apigatewayv2_api.aws-websocket-example-apg.id
  integration_type   = "AWS_PROXY"
  description        = "Connect Integration"
  integration_uri    = aws_lambda_function.OnConnectFunction.invoke_arn
}

resource "aws_apigatewayv2_route" "ConnectRoute" {
  api_id         = aws_apigatewayv2_api.aws-websocket-example-apg.id
  route_key      = "$connect"
  operation_name = "ConnectRoute"
  target         = "integrations/${aws_apigatewayv2_integration.ConnectIntegration.id}"

}

resource "aws_apigatewayv2_route" "DisconnectRoute" {
  api_id         = aws_apigatewayv2_api.aws-websocket-example-apg.id
  route_key      = "$disconnect"
  operation_name = "DisconnectRoute"
  target         = "integrations/${aws_apigatewayv2_integration.ConnectIntegration.id}"

}

resource "aws_apigatewayv2_route" "DefaultRoute" {
  api_id         = aws_apigatewayv2_api.aws-websocket-example-apg.id
  route_key      = "$default"
  operation_name = "DefaultRoute"
  target         = "integrations/${aws_apigatewayv2_integration.ConnectIntegration.id}"
}
