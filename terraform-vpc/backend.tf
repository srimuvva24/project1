terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket0827"   # Replace with your S3 bucket name
    key            = "alb-vpc/terraform.tfstate"   # Path inside the bucket
    region         = "us-east-2"                   # S3 bucket region
    encrypt        = true                          # Encrypt state at rest with SSE-S3
  }
}
