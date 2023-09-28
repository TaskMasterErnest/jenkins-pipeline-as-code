packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source = "github.com/hashicorp/amazon"
    }
  }
}

# initializing variables
variable "ami_name" {
  type = string
  default = "jenkins-master-ami"
}
variable "instance_type" {
  type = string
  default = "t2.micro"
}
variable "default_region" {
  type = string
  default = "eu-west-2"
}
variable "image_name" {
  type = string
  default = "amzn2-ami-amd-hvm-2.0.20230221.0-x86_64-gp2"
}
variable "build_name" {
  type = string
  default = "master"
}


source "amazon-ebs" "jenkins_master" {
  ami_name      = "${var.ami_name}"
  instance_type = "${var.instance_type}"
  region        = "${var.default_region}"
  source_ami_filter {
    filters = {
      name                = "${var.image_name}"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username = "ec2-user"
}

build {
  name = "${var.build_name}"
  sources = [
    "source.amazon-ebs.jenkins_master"
  ]

  provisioner "shell" {
    execute_command = "sudo -E -S sh '{{ .Path }}'"
    script          = "./setup.sh"
  }
}