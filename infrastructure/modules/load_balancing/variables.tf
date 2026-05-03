
variable "vpc_id" {
    description = "ID of the VPC"
    type = string
}

variable "alb_name" {
    description = "Name of the Application Load Balancer"
    type = string
}

variable "alb_sg_id" {
  description = "alb sg id"
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
  description = "List of public subnet IDs for the ALB (must be at least 2 in different AZs)"
}

variable "worker1_instance_id" {
  type = string
  description = "Instance ID of the Worker node"
}