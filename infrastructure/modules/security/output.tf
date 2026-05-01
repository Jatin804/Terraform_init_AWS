
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