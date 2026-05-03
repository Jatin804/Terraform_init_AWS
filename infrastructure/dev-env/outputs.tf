# networking output 
output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

# alb output
output "alb_dns_name" {
  value       = module.load_balancing.alb_dns_name
  description = "The DNS URL of the Application Load Balancer"
}

# security group output
output "alb_sg_id" {
    value = module.security.alb_sg_id
}

output "bastion_sg_id" { 
    value = module.security.bastion_sg_id 
}

output "jenkins_sg_id" { 
    value = module.security.jenkins_sg_id
}

output "master_sg_id" {
    value = module.security.master_sg_id 
}

output "worker_sg_id" {
    value = module.security.worker_sg_id 
}


output "jenkins_iam_profile" { 
    value = module.security.jenkins_iam_profile
}

output "k8s_node_iam_profile" { 
    value = module.security.k8s_node_iam_profile
}

output "flask_application_url" {
  value       = "http://${module.load_balancing.alb_dns_name}"
  description = "The public URL to view your deployed Flask application."
}

output "bastion_public_ip" {
  value       = module.compute.bastion_public_ip
  description = "Public IP of the Bastion Host."
}

output "bastion_ssh_command" {
  value       = "ssh -i ~/.ssh/id_ed25519 -A ubuntu@${module.compute.bastion_public_ip}"
  description = "Command to securely SSH into your Bastion Host."
}

output "jenkins_instance_id" {
  value       = module.compute.jenkins_instance_id
  description = "Instance ID of Jenkins server."
}

output "master_instance_id" {
  value       = module.compute.master_instance_id
  description = "Instance ID of Kubernetes Master."
}

output "worker1_instance_id" {
  value       = module.compute.worker1_instance_id
  description = "Instance ID of Kubernetes Worker 1."
}


