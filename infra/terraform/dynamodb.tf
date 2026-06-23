# Uma tabela DynamoDB por ambiente: Veiculos-<env>. PK = id (uuid).
resource "aws_dynamodb_table" "veiculos" {
  for_each = local.environments

  name         = "Veiculos-${each.key}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Environment = each.key
    Component   = "DynamoDB"
  }
}
