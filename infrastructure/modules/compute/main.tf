data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "aws_key_instance" {
  key_name = var.key_name
  public_key = file(var.ssh_private_key_path)
}

resource "aws_instance" "bastion" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.bastion_type
  key_name = aws_key_pair.aws_key_instance.key_name
  vpc_security_group_ids = [var.bastion_sg_id]
  subnet_id = var.public_subnet_id
  
  tags = { Name = "Bastion-Host" }
}

resource "aws_instance" "jenkins" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.aws_instance_type
  key_name = aws_key_pair.aws_key_instance.key_name
  vpc_security_group_ids = [var.jenkins_sg_id]
  subnet_id = var.private_subnet_id
  iam_instance_profile = var.jenkins_iam_profile
  
  tags = { Name = "Jenkins" }

  user_data = file(var.jenkins_script)

}

resource "aws_instance" "master" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.aws_instance_type
  key_name = aws_key_pair.aws_key_instance.key_name
  vpc_security_group_ids = [var.master_sg_id]
  subnet_id = var.private_subnet_id
  iam_instance_profile = var.k8s_node_iam_profile
  
  tags = { Name = "Master" }

  user_data = file(var.master_script)
}

resource "aws_instance" "worker1" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.aws_instance_type
  key_name = aws_key_pair.aws_key_instance.key_name
  vpc_security_group_ids = [var.worker_sg_id]
  subnet_id = var.private_subnet_id
  iam_instance_profile = var.k8s_node_iam_profile
  
  tags = { Name = "Worker1" }

  user_data = file(var.worker_script)
}