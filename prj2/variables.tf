terraform {
  required_version = "> 0.7.0"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}

variable "domain_name" {
  default = "webinfra"
}

variable "author" {
  default = "VDY"
}

variable "env" {
  default = "DEV"
}

variable "generator" {
  default = "terraform"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_user" {
  default = "ec2-user"
}

variable "access_key" {}
variable "secret_key" {}

/*
variable "ami_id" {
  default = "ami-70edb016"
}
*/

variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub

You should ceate key first :
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f terraform

DESCRIPTION

  default = "~/.ssh/terraform.pub"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default     = "webinfra_key"
}

# Amazon Linux AMI 2016.09.1 (HVM), SSD Volume Type
variable "aws_amis" {
  default = {
    eu-west-1 = "ami-70edb016"
    us-east-1 = "ami-0b33d91d"
    us-west-1 = "ami-165a0876"
    us-west-2 = "ami-f173cc91"
  }
}
