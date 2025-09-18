# Multi-Cloud Kubernetes with Terraform and Consul

This project provides a robust, minimal setup for a multi-cloud Kubernetes architecture spanning AWS and Google Cloud Platform (GCP). It uses Terraform for infrastructure provisioning, AWS Route 53 for DNS-based failover, and HashiCorp Consul for cross-cluster service discovery and service mesh capabilities.

The primary goal is to create a resilient Active-Passive setup where AWS serves as the primary region and GCP acts as a hot standby.

## Core Architecture

The architecture is divided into two main traffic patterns:

1.  **North-South Traffic (User to Application):** Managed by AWS Route 53. User requests are directed to the primary AWS region (set as ap-south-1 in this example). If health checks for the AWS Application Load Balancer (ALB) fail, Route 53 automatically reroutes all traffic to the GCP Cloud Load Balancer.

2.  **East-West Traffic (Service-to-Service):** Managed by HashiCorp Consul. A federated Consul service mesh is deployed across both Kubernetes clusters. This allows services to communicate seamlessly with each other across cloud boundaries using consistent DNS names (e.g., `billing-api.service.consul`), regardless of which region is currently active. This will be used by our K8s-services.
---

## Directory Structure

```
├── consul/
│   ├── consul-aws-values.yaml      # Helm values for the primary AWS Consul datacenter
│   └── consul-gcp-values.yaml      # Helm values for the secondary GCP Consul datacenter
│
└── infra/
    ├── aws/                        # Terraform root module for all AWS resources
    ├── gcp/                        # Terraform root module for all GCP resources
    ├── dns/                        # Terraform root module for Route 53 failover records
    ├── global/                     # Terraform for global resources (Route 53 Zone, TF state backends)
    ├── modules/                    # Reusable Terraform modules (EKS, GKE, VPC, etc.)
    └── scripts/                    # Helper scripts for running Terraform
```

---

## Deployment Guide

Follow these steps to provision the entire multi-cloud environment.

### Prerequisites

1.  **Tools:**
    *   Terraform (`>= 1.0`)
    *   AWS CLI (`>= 2.0`)
    *   Google Cloud SDK (`gcloud`)
    *   `kubectl`
    *   `helm`
2.  **Configuration:**
    *   Ensure your AWS and GCP credentials are configured locally.
    *   Purchase a domain name and have it managed by AWS Route 53.

### Step 1: Global Backend Setup

Terraform state is stored remotely to enable collaboration and secure state management. This project uses AWS S3 with DynamoDB for the AWS/DNS state and GCS for the GCP state.

The `plan.sh` and `apply.sh` helper scripts will create global backend on AWS and GCP and store it's state locally. 

Ideally, the initial creation of the infrastructure to hold remote state should be done manually, so we are not storing `.tfstate` locally. However, for this project, the creation of the global backend is through Terraform and local-state.

### Step 2: Provision Cloud Infrastructure

Use the provided scripts to deploy the infrastructure in the correct order. The scripts manage Terraform initialization and workspace selection.

**Deployment Order is Critical:**

1.  **Global:** Creates the Route 53 Hosted Zone along with the remote backend for both AWS and GCP.
    ```bash
    cd infra/scripts
    ./run_tf_command.sh apply ../global staging
    ```

2.  **AWS (Primary Region):** Deploys the VPC, EKS cluster, ALB, RDS, and Redis.
    ```bash
    ./run_tf_command.sh apply ../aws staging
    ```

3.  **GCP (Secondary Region):** Deploys the VPC, GKE cluster, and Cloud Load Balancer.
    ```bash
    ./run_tf_command.sh apply ../gcp staging
    ```

4.  **DNS:** Configures the Route 53 failover records. This must be last as it depends on outputs from both the AWS and GCP deployments.
    ```bash
    ./run_tf_command.sh apply ../dns staging
    ```

### Step 3: Configure `kubectl`

After provisioning, configure `kubectl` to communicate with your new clusters.

*   **For EKS (AWS):**
    ```bash
    aws eks update-kubeconfig --region <your-aws-region> --name <your-eks-cluster-name>
    ```
*   **For GKE (GCP):**
    ```bash
    gcloud container clusters get-credentials <your-gke-cluster-name> --region <your-gcp-region>
    ```

### Step 4: Deploy Consul Service Mesh

Consul is deployed using Helm after the infrastructure is ready. This process involves a few manual steps to securely link the two datacenters.

1.  **Get GCP Egress IPs:** Find the static outbound IP addresses of your GCP cluster. This is used to firewall the AWS Consul endpoint.
    ```bash
    terraform -chdir=infra/gcp output nat_egress_ips
    ```
    Copy the output and replace the placeholder IPs in `consul/consul-aws-values.yaml` under the `loadBalancerSourceRanges` annotation.

2.  **Deploy Consul to AWS (Primary):** Switch your `kubectl` context to the EKS cluster.
    ```bash
    helm repo add hashicorp https://helm.releases.hashicorp.com
    helm install consul hashicorp/consul --values consul/consul-aws-values.yaml --namespace consul --create-namespace
    ```

3.  **Get AWS Consul Load Balancer Address:** Wait a few minutes for the AWS Load Balancer to be provisioned, then retrieve its address.
    ```bash
    kubectl get service consul-server -n consul -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
    ```
    Copy the output address (e.g., `xxxx.elb.us-east-1.amazonaws.com`).

4.  **Update GCP Consul Config:** Paste the AWS Load Balancer address into `consul/consul-gcp-values.yaml`, replacing the `<REPLACE_WITH_AWS_LOAD_BALANCER_ADDRESS>` placeholder in the `retry_join` block.

5.  **Deploy Consul to GCP (Secondary):** Switch your `kubectl` context to the GKE cluster.
    ```bash
    helm install consul-gcp hashicorp/consul --values consul/consul-gcp-values.yaml --namespace consul --create-namespace
    ```

Your multi-cloud service mesh is now operational! You can verify the federation by port-forwarding to the Consul UI and checking that both `aws` and `gcp` datacenters are visible.

---

## Technology Stack

*   **Cloud Providers:** AWS, Google Cloud Platform
*   **IaC:** Terraform
*   **Container Orchestration:** Amazon EKS, Google GKE
*   **DNS & Failover:** AWS Route 53
*   **Service Mesh:** HashiCorp Consul
*   **Databases:** Amazon RDS (Postgres), Amazon ElastiCache (Redis)
*   **Load Balancing:** AWS Application Load Balancer, GCP Global Cloud Load Balancer
*   **Ingress Controllers:** AWS Load Balancer Controller (for EKS), GKE Ingress Controller
