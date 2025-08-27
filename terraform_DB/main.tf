provider "aws" {
  region = var.aws_region
}

resource "aws_dynamodb_table" "candidate_table" {
  name         = "Candidates"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "CandidateName"

  attribute {
    name = "CandidateName"
    type = "S"
  }
}
