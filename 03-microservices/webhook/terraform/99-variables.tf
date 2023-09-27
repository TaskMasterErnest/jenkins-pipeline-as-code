variable "aws_region" {
  description = "AWS region to deploy Lambda and API Gateway in"
  type = string
  default = "eu-west-2"
}

variable "shared_credentials_file" {
  description = "the credentials file to authenticate the Terraform init"
  type = string
  default = "/home/ernestklu/.aws/credentials"
}

variable "aws_profile" {
  description = "the profile used for authenticating Terraform with AWS"
  type = string
}

variable "jenkins_url" {
  description = "name of the Jenkins URL"
  type = string
  default = "jenkins.thetaskmasterernest.cyou"
}