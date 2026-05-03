# Network Module
module "networking" {
  source = "../modules/networking"

  aws_vpc_cidr = var.aws_vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zones = var.availability_zones
  route_cidr = var.route_cidr
  tags = var.tags
  nat_availability_mode = "public"
}

# Security Groups & IAM Roles
module "security" {
  source = "../modules/security"

  vpc_id = module.networking.vpc_id
  alb_name = var.alb_name
  ssh_rules = var.ssh_rules
  master_ingress_rules = var.master_ingress_rules
  worker_ingress_rules = var.worker_ingress_rules
}

#  EC2 Instances
module "compute" {
  source = "../modules/compute"

  ami_id = var.ami_id
  aws_instance_type = var.aws_instance_type
  bastion_type = var.bastion_type
  key_name = var.key_name
  ssh_private_key_path = var.ssh_private_key_path


  bastion_sg_id = module.security.bastion_sg_id
  jenkins_sg_id = module.security.jenkins_sg_id
  master_sg_id = module.security.master_sg_id
  worker_sg_id = module.security.worker_sg_id

  # Attach Subnets
  public_subnet_id = module.networking.public_subnet_ids[0]
  private_subnet_id = module.networking.private_subnet_ids[0]

  # Attach Least Privilege IAM Roles
  jenkins_iam_profile = module.security.jenkins_iam_profile
  k8s_node_iam_profile = module.security.k8s_node_iam_profile

  jenkins_script = "../scripts/install_jenkins.sh"
  master_script = "../scripts/k8s_master.sh"
  worker_script = "../scripts/k8s_worker.sh"
}

# 4. Attach the Load Balancer
module "load_balancing" {
  source = "../modules/load_balancing"

  alb_name = var.alb_name
  vpc_id = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  alb_sg_id = module.security.alb_sg_id
  worker1_instance_id = module.compute.worker1_instance_id
}