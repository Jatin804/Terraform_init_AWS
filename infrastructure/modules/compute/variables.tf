variable "ami_id" {
    description = "ami names for insance"
    type = string
}

variable "aws_instance_type" {
    description = "aws instance type"
    type = string
}

variable "bastion_type" {
    description = "aws instance type for bastion host"
    type = string
}

variable "key_name" {
  description = "Name of the SSH key pair to use for the instances"
  type        = string
}

# using existing key
variable "ssh_private_key_path" {
  type = string
}

variable "public_subnet_id" {
    description = "ID of the public subnet for the Bastion"
    type = string
}

variable "private_subnet_id" {
    description = "ID of the private subnet for Core Instances"
    type = string
}

variable "bastion_sg_id" { 
    description = "security group for bastion"
    type = string 
}

variable "jenkins_sg_id" { 
    description = "security group for jenkins"
    type = string 
}

variable "master_sg_id" { 
    description = "security group for master"
    type = string 
}
variable "worker_sg_id" { 
    description = "security group for worker"
    type = string 
}

variable "master_script" {
    description = "Kubernetes Master script"
    type = string
}

variable "worker_script" {
    description = "Kubernetes Worker script"
    type = string
}

variable "jenkins_script" {
    description = "Jenkins script"
    type = string
}