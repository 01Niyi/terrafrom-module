# store the terraform state file in s3
terraform {
  backend "s3" {
    bucket    = "tfneyor"
    key       = "dev/2023new.tfstate"
    region    = "us-east-1"
  }
}