# IAM policy 

# Trust Policy: Allows EC2 instances to assume these roles
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Jenkins Role: For the Jenkins instance to interact with AWS services
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins_role_least_privilege"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "jenkins_ssm" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Kubernetes Nodes Role: For the Kubernetes worker nodes to interact with AWS services
resource "aws_iam_role" "k8s_node_role" {
  name               = "k8s-node-least-privilege-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "k8s_node_ssm" {
  role       = aws_iam_role.k8s_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Profiles: To attach the IAM roles to EC2 instances
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins_role.name
}

resource "aws_iam_instance_profile" "k8s_node_profile" {
  name = "k8s-node-instance-profile"
  role = aws_iam_role.k8s_node_role.name
}

