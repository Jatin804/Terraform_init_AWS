# Security Groups


# Security group for ALB
resource "aws_security_group" "alb_sg" {
    name = var.alb_name
    description = "Security group for Application Load Balancer"
    vpc_id = var.vpc_id

    ingress {
        description = "Http access from anywhere"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Bastion Host security group
resource "aws_security_group" "bastion_sg" {
    name = "bastion-sg"
    description = "Bastion Host SSH access only"
    vpc_id = var.vpc_id

    ingress {
        description = "SSH access for bastion host"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port = 22
        description = "SSH access for bastion host"
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }
}
  
resource "aws_security_group" "master_sg" {
  name        = "master-sg"
  description = "Master node security group"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.master_ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ["10.0.0.0/16"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Worker Nodes security group
resource "aws_security_group" "worker_sg" {
    name = "worker-sg"
    description = "Worker node secirity group"
    vpc_id = var.vpc_id

    dynamic "ingress" {
      for_each = var.worker_ingress_rules
      content {
        description = ingress.value.description
        from_port   = ingress.value.from_port
        to_port     = ingress.value.to_port
        protocol    = ingress.value.protocol
        cidr_blocks = ["10.0.0.0/16"]
      }
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        description = "Allow all outbound traffic"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}

# Jenkins security group
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Jenkins CI/CD Server Rules"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH ONLY from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    description = "Allow Outbound to Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group_rule" "alb_to_worker_egress" {
  type                     = "egress"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.worker_sg.id
  security_group_id        = aws_security_group.alb_sg.id
  description              = "Restrict ALB outbound specifically to Worker SG"
}


# To avoid a circular dependency block in Terraform
resource "aws_security_group_rule" "master_from_worker" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.worker_sg.id
  security_group_id        = aws_security_group.master_sg.id
  description              = "Allow all internal K8s traffic from Worker to Master"
}

resource "aws_security_group_rule" "worker_from_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.master_sg.id
  security_group_id        = aws_security_group.worker_sg.id
  description              = "Allow all internal K8s traffic from Master to Worker"
}
