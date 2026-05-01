variable "aws_region" {
    type = string 
}

variable "aws_vpc_cidr" { 
    type = string
}

variable "public_subnet_cidr" { 
    type = list(string) 
}

variable "private_subnet_cidr" { 
    type = list(string) 
}

variable "availability_zones" { 
    type = list(string) 
}

variable "route_cidr" { 
    type = string
}

variable "tags" { 
    type = map(string)
}

variable "alb_name" { 
    type = string
}

variable "aws_instance_type" { 
    type = string
}

variable "bastion_type" { 
    type = string 
}

variable "key_name" {
    type = string
}

variable "ssh_private_key_path" { 
    type = string 
}

variable "master_ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
}

variable "worker_ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
}