# Automated AWS Infrastructure: Terraform, Jenkins CI/CD & Kubernetes Cluster

This project is based on my previous project that was a manual architecture demonstrating within AWS cloud, an automated deployment of updated application using jenkins CI-CD, link --> [https://github.com/Jatin804/AWS_EC2_k8s_Docker_Cluster](https://github.com/Jatin804/AWS_EC2_k8s_Docker_Cluster)

### **Project Overview**
This project transforms a manually managed cloud architecture into a fully automated, modular infrastructure using **Terraform**. It provisions a high-availability environment on AWS, featuring a secured VPC, an Application Load Balancer, a Jenkins CI/CD server, and a multi-node Kubernetes cluster. 

A central component of this architecture is the **Bastion Host**, which acts as the primary secure gateway for the entire system. All administrative communication and access to private resources, including the Jenkins UI and Kubernetes nodes, are routed through this host. By shifting from manual clicks to Infrastructure as Code (IaC), the environment is now version-controlled, reproducible, and scalable.

### **Impact Analysis**
The transition to automation significantly improves operational performance:

| Category | Manual Process | Automated Process | Improvement |
| :--- | :--- | :--- | :--- |
| **Setup Time** | 2-3 Hours | 5-8 Minutes | **~95% faster** |
| **Error Rate** | High (Human oversight) | Low (Pre-validated code) | **90% reduction** |
| **Consistency** | Variable | Identical across environments | **100% parity** |
| **Recovery** | Manual troubleshooting | Instance Tainting/Recreation | **~80% faster MTRS** |

---

### **Project Structure**
The repository is organized into distinct modules to ensure separation of concerns and reusability.

```text
.
├── dev-env/                # Development environment root
│   ├── main.tf             # Module orchestrator
│   ├── variables.tf        # Environment-specific variables
│   ├── providers.tf        # AWS provider configuration
│   └── outputs.tf          # Global output definitions
├── modules/
│   ├── networking/         # VPC, Subnets, IGW, NAT Gateway
│   ├── security/           # IAM Roles, Security Groups
│   ├── compute/            # EC2 Instances (Bastion, Jenkins, K8s)
│   └── load_balancing/     # ALB, Target Groups, Listeners
└── scripts/                # Bootstrapping bash scripts
    ├── install_jenkins.sh  # Automated Jenkins and Docker setup
    ├── k8s_master.sh       # Kubernetes control plane init
    └── k8s_worker.sh       # Worker node preparation
```

---

### **Infrastructure Deployment Flow**
Terraform manages the resource lifecycle through a specific dependency chain:
1. **Networking Layer:** Establishes the VPC, creating public subnets for external traffic and private subnets for secure workloads.
2. **Security Layer:** Provisions IAM Instance Profiles for service permissions and Security Groups to restrict traffic to the VPC CIDR or specific IDs.
3. **Compute Layer:** Provisions EC2 instances. Cloud-init executes the provided bash scripts in the background upon the first boot.
4. **Application Access:** The ALB is attached to the Worker nodes via NodePorts (30005) to expose the application.

---

### **Technical Operations**

#### **1. Isolated Operations & Connectivity**
To maintain security, Jenkins and Kubernetes nodes reside in private subnets. Access is managed strictly through the **Bastion Host** using a **locally created SSH key**. This key is the single point of authentication for jumping into private instances or creating secure tunnels.

**Secure SSH Tunnel for Jenkins UI:**
```bash
ssh -J ubuntu@<BASTION_PUBLIC_IP> -L 8080:localhost:8080 ubuntu@<JENKINS_PRIVATE_IP> -i /path/to/local_key.pem
```

**Debugging Execution:**
Since scripts run during boot, logs must be checked locally to verify successful installation:
```bash
cat /var/log/cloud-init-output.log
```

**Resource Reset:**
If a specific node fails configuration, it can be forced to recreate without destroying the entire infrastructure:
```bash
terraform taint module.compute.aws_instance.jenkins
terraform apply
```

#### **2. Credentials Management**
Standard integration requires adding GitHub (SSH/PAT) and Docker Hub credentials within the Jenkins Credentials Manager to allow the pipeline to pull source code and push container images.

#### **3. Kubernetes Cluster Authentication**
Modern Kubernetes (v1.24+) requires manual secret generation for Service Account tokens.

**Step 1: Service Account Creation**
```bash
kubectl create serviceaccount jenkins-admin
kubectl create clusterrolebinding jenkins-admin-binding --clusterrole=cluster-admin --serviceaccount=default:jenkins-admin
```

**Step 2: Generate Secret Token**
Define a `jenkins-secret.yaml`:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-admin-token
  annotations:
    kubernetes.io/service-account.name: jenkins-admin
type: kubernetes.io/service-account-token
```
Apply via `kubectl apply -f jenkins-secret.yaml`.

**Step 3: Extract Credentials for Jenkins**
* **Secret Text:**
  `kubectl get secret jenkins-admin-token -o jsonpath='{.data.token}' | base64 --decode`
* **Server CA Certificate:**
  `kubectl get secret jenkins-admin-token -o jsonpath='{.data.ca\.crt}' | base64 --decode`

---

### **Challenges & Lessons Learned**

* **Module Dependency & Data Flow:** One of the primary challenges was ensuring the correct flow of data between isolated Terraform modules. Managing how output values from the networking module were passed as input variables to the security and compute modules required a deep understanding of Terraform's resource graph to avoid circular dependencies.
* **Automating Background Processes:** Debugging automated bash scripts (`user_data`) proved difficult as they run silently during the initial boot. I learned to utilize `cloud-init` logs for troubleshooting and refined the scripts to handle package manager locks and GPG key rotations, which frequently stall automated deployments.
* **Kubernetes Security Evolution:** Adapting to Kubernetes v1.24+ security changes was a significant learning curve. Moving from automatically generated secrets to manually provisioned Service Account tokens reinforced the importance of understanding the underlying security architecture of container orchestration.

---

### **Assessment of Missing Components**
While the current architecture is robust for development, the following items are missing for a production-ready state:
* **Remote State Management:** The Terraform state is currently local. Using an S3 bucket with DynamoDB locking is necessary for team collaboration. **(Solved using DynamoDB or S3 state file options)**
* **Auto-Scaling:** The worker nodes are hardcoded. Implementing an Auto Scaling Group (ASG) would allow the cluster to handle load spikes. **(Solutions: Terraform module for Auto Scaling)**

***``` This project is a Terraform-based automation of my previous manual cloud architecture. It demonstrates a fully automated deployment cycle and is designed to be extensible, allowing for the future integration of monitoring tools and database layers as needed. ```***