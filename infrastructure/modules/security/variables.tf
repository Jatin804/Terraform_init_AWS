
variable "vpc_id" {
    description = "ID of the VPC"
    type = string  
}

variable "alb_name" {
    description = "Name of the Application Load Balancer"
    type = string
}

variable "ssh_rules" {
    description = "SSH ingress and egress rules"
    type = map(list(string))
}

variable "master_ingress_rules" {
  description = "List of ingress rules for the Master nodes"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))
}

variable "worker_ingress_rules" {
  description = "List of ingress rules for the Worker nodes"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))
}

