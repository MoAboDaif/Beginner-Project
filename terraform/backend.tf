resource "aws_s3_bucket" "backend" {
  count  = terraform.workspace == "default" ? 1 : 0
  bucket = "moabodaif-terraform-s3-backend"
}

resource "aws_dynamodb_table" "backend_lock" {
  count          = terraform.workspace == "default" ? 1 : 0
  name           = "backend-lock-table"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
