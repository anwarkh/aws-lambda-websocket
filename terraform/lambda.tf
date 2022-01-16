locals {
  file ="${path.module}/../dist/connectionFunction.zip"
  name = "connection"
}

/*data "archive_file" "connection_function_archive" {
  type = "zip"
  source_dir  = "${path.module}/../dist"
  output_path = "${path.module}/../dist/OnConnectFunction.zip"

}*/

//resource "aws_lambda_layer_version" "dependency_layer" {
//  filename = "${path.module}/../dist/layers/layers.zip"
//  layer_name = "dependency_layer"
//  compatible_runtimes = ["nodejs14.x"]
//  source_code_hash = base64sha256(filebase64("${path.module}/../dist/layers/layers.zip"))
//}

resource "aws_lambda_function" "connectionFunction" {
  filename = local.file
  function_name = local.name
  role = aws_iam_role.lambda_role.arn
  handler = "connectionFunction/connectHandler.handle"
  runtime = "nodejs14.x"
  timeout = "15"
  memory_size = local.lambda_memory
  source_code_hash = filebase64sha256(local.file)
//  layers = [ aws_lambda_layer_version.dependency_layer.arn ]
  environment {
    variables = {
      CONNECTIONS_TABLE = aws_dynamodb_table.ConnectionsTable.name
    }
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.connectionFunction.function_name
  principal = "apigateway.amazonaws.com"
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${aws_lambda_function.connectionFunction.function_name}"
  retention_in_days = 14
}
