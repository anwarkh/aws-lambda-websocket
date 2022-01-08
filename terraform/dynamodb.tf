#
# DynamoDB table resources.
#
resource "aws_dynamodb_table" "ConnectionsTable" {
  name           = "websocket_connections"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "connectionId"

  attribute {
    name = "connectionId"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }
}

