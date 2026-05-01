# networking output 
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public-subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private-subnet[*].id
}

# alb output
output "alb_dns_name" {
  value       = aws_lb.flask_alb.dns_name
  description = "The DNS URL of the Application Load Balancer"
}

# security group output
output "alb_sg_id" {
    value = aws_security_group.alb_sg.id
}

output "bastion_sg_id" { 
    value = aws_security_group.bastion_sg.id 
}

output "jenkins_sg_id" { 
    value = aws_security_group.jenkins_sg.id 
}

output "master_sg_id" {
    value = aws_security_group.master_sg.id 
}

output "worker_sg_id" {
    value = aws_security_group.worker_sg.id 
}


output "jenkins_iam_profile" { 
    value = aws_iam_instance_profile.jenkins_profile.name 
}

output "k8s_node_iam_profile" { 
    value = aws_iam_instance_profile.k8s_node_profile.name 
}

output "flask_application_url" {
  value       = "http://${module.load_balancing.alb_dns_name}"
  description = "The public URL to view your deployed Flask application."
}

output "bastion_ssh_command" {
  value       = "ssh -i ~/.ssh/id_ed25519 -A ubuntu@${module.compute.bastion_public_ip}"
  description = "Command to securely SSH into your Bastion Host."
}


