# Terraform code to set up the AWS environment
# It automatically uses the already configured credentials but we have to specify them here too
provider "aws" {
  region = var.region
  shared_credentials_files = var.shared_credentials_file
  profile = var.aws_profile
}