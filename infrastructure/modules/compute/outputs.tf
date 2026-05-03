output "bastion_instance_id" {
  value       = aws_instance.bastion.id
  description = "Instance ID of the Bastion Host"
}

output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Public IP of the Bastion Host"
}

output "jenkins_instance_id" {
  value       = aws_instance.jenkins.id
  description = "Instance ID of Jenkins server"
}

output "jenkins_private_ip" {
  value       = aws_instance.jenkins.private_ip
  description = "Private IP of Jenkins server"
}

output "master_instance_id" {
  value       = aws_instance.master.id
  description = "Instance ID of Kubernetes Master"
}

output "master_private_ip" {
  value       = aws_instance.master.private_ip
  description = "Private IP of Kubernetes Master"
}

output "worker1_instance_id" {
  value       = aws_instance.worker1.id
  description = "Instance ID of Kubernetes Worker 1"
}

output "worker1_private_ip" {
  value       = aws_instance.worker1.private_ip
  description = "Private IP of Kubernetes Worker 1"
}
