data "aws_iam_policy_document" "lambda_assume_role_document" {
  version = "2012-10-17"

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "CloudWatchLogsPolicyDocument" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "cloudwatch:PutMetricData",
      "kms:*"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "executeApiPolicyDocument" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    actions = [
      "execute-api:Invoke",
      "execute-api:ManageConnections"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "CloudWatchLogsPolicy" {
  policy = data.aws_iam_policy_document.CloudWatchLogsPolicyDocument.json
}
resource "aws_iam_policy" "ExecuteApiPolicy" {
  policy = data.aws_iam_policy_document.executeApiPolicyDocument.json
}

resource "aws_iam_role" "lambda_role" {
  name = "${local.name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_document.json
  tags = local.tags
}




#################### DynamoDB #################
resource "aws_iam_policy" "DynamoDBCrudPolicy" {
  name = "DynamoDBCrudPolicy"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:PutItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:BatchGetItem",
      "dynamodb:DescribeTable"
    ],
    "Resource": [
      "${aws_dynamodb_table.ConnectionsTable.arn}",
      "${aws_dynamodb_table.ConnectionsTable.arn}/index/*"
    ]
  }]
}
EOT
}
resource "aws_iam_policy_attachment" "CloudWatchLogsPolicy_iam_policy_attachment" {
  name = "${local.name}-aws_iam_policy_attachment"
  roles = [ aws_iam_role.lambda_role.name ]

  policy_arn = aws_iam_policy.CloudWatchLogsPolicy.arn
}

resource "aws_iam_policy_attachment" "ExecuteApiPolicy_iam_policy_attachment" {
  name = "${local.name}-aws_iam_policy_attachment"
  roles = [ aws_iam_role.lambda_role.name ]

  policy_arn = aws_iam_policy.ExecuteApiPolicy.arn
}

resource "aws_iam_policy_attachment" "DynamoDBCrudPolicy_iam_policy_attachment" {
  name = "${local.name}-DynamoDBCrudPolicy_iam_policy_attachment"
  roles = [ aws_iam_role.lambda_role.name ]
  policy_arn = aws_iam_policy.DynamoDBCrudPolicy.arn
}

