# Envionment Variables
######################################################################################################

variable "name" {
  description = "Base name for resources"
  type        = string
  default     = "iac-jenkins"
}

variable "environment_type" {
  description = "type of the environment we are building"
  type        = string
  default     = "test"
}

variable "region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "eu-west-2"
}

variable "zones" {
  description = "The AWS availability zone to deploy to"
  type        = list(any)
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "default_tags" {
  description = "The default tags to use across all of our resources"
  type        = map(any)
  default = {
    project     = "iac-jenkins"
    environment = "prod"
    deployed_by = "terraform"
  }
}

# Networking Variables
######################################################################################################

# variable "network_trusted_ips" {
#   description = "Optional list if IP addresses which need access, your current IP will be added automatically"
#   type        = list(any)
#   default = [
#   ]
# }

variable "vpc_address_space" {
  description = "The address space of VPC"
  type        = string
  default     = "10.0.0.0/16"
}


# Bastion Host Variables
######################################################################################################
variable "public_key" {
  description = "Public SSH key for bastion host"
  type = string
  default = "/home/ernestklu/.ssh/bastion_host.pub"
}

variable "ami_most_recent" {
  description = "should the most recent version of the AMi be used?"
  type = bool
  default = true
}

variable "ami_owners" {
  description = "who owns the AMI to be used"
  type = string
  default = "amazon"
}

variable "ami_filter_name" {
  description = "which AMI should be used"
  type = string
  default = "al2023-ami-2023.1.20230906.1-kernel-6.1-x86_64"
}

variable "ami_filter_virtualization_type" {
  description = "what type of virtualization should be used"
  type = string
  default = "hvm"
}


# Jenkins Master Variables
######################################################################################################
variable "jenkins_master_instance_type" {
  description = "which instance type should be used for the master?"
  type = string
  default = "t2.large"
}


# AWS SSL ARN Variables
######################################################################################################
variable "ssl_arn" {
  description = "the SSL ARN from the ACM"
  type = string
  default = "arn:aws:acm:eu-west-2:478429420160:certificate/63d4c16e-e92d-4e4a-a2fe-9c25ddde893e"
}

variable "hosted_zone_id" {
  description = "The ID of the Hosted Zone"
  type = string
  default = "Z020009338AOOFJJHZ7EE"
}

variable "domain_name" {
  description = "The domain name that is hosted"
  type = string
  default = "thetaskmasterernest.cyou"
}


# JENKINS WORKER VARIABLES
######################################################################################################
variable "jenkins_username" {
  description = "Jenkins admin username"
  type = string
}

variable "jenkins_password" {
  description = "Jenkins admin password"
  type = string 
}

variable "jenkins_credentials_id" {
  description = "Jenkins worker SSH-based credentials ID"
  type = string 
}

variable "jenkins_worker_instance_type" {
  description = "Jenkins worker EC2 instance type"
  type = string 
  default = "t2.medium"
}