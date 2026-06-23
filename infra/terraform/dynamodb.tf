# DynamoDB Table for Veiculos Entity

resource "aws_dynamodb_table" "veiculos" {
  name         = "Veiculos-${var.environment}"
  billing_mode = var.dynamodb_billing_mode
  hash_key     = "placa"

  # Single-table design with placa as partition key
  attribute {
    name = "placa"
    type = "S"
  }

  # Point-in-Time Recovery (PITR)
  point_in_time_recovery {
    enabled = true
  }

  # Server-side encryption (default AES256)
  server_side_encryption {
    enabled = true
  }

  # Tags
  tags = {
    Project     = "testproject"
    Environment = var.environment
    Component   = "DynamoDB"
  }

  # Stream configuration (enabled for future AWS Lambda triggers)
  stream_enabled   = var.dynamodb_enable_stream
  stream_view_type = "NEW_AND_OLD_IMAGES"

  # Read/write capacity units (only used when billing_mode is PROVISIONED)
  read_capacity  = var.dynamodb_billing_mode == "PROVISIONED" ? var.dynamodb_read_capacity : null
  write_capacity = var.dynamodb_billing_mode == "PROVISIONED" ? var.dynamodb_write_capacity : null

  # Lifecycle configuration
  # Note: prevent_destroy cannot use function calls in Terraform
  # Manual intervention required before deleting production tables
  lifecycle {
    # prevent_destroy = true  # Uncomment for staging/production after initial deployment
  }
}
