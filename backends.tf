terraform {
  backend "s3" {
    bucket = "aws-s3-tfm-state-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}