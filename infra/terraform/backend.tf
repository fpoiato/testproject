terraform {
  backend "s3" {
    bucket         = "testproject-tfstate-986873053420"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "testproject-tflock"
    encrypt        = true
  }
}
