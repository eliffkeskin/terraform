# eks

EKS cluster in Auto Mode, built on the `network` module from `vpc-alb`. No managed node groups, no Cluster Autoscaler, no add-on installation: AWS runs the nodes, the block storage driver and the load balancer controller. Nodes appear when pods are pending and disappear when they are gone.

## What it creates

- VPC with 2 public and 2 private subnets, IGW, NAT gateway (via `../vpc-alb/modules/network`)
- Cluster IAM role trusted by `eks.amazonaws.com` with the five Auto Mode policies (Cluster, Compute, BlockStorage, LoadBalancing, Networking)
- Node IAM role trusted by `ec2.amazonaws.com` with `AmazonEKSWorkerNodeMinimalPolicy` and `AmazonEC2ContainerRegistryPullOnly`
- `aws_eks_cluster` in the private subnets, authentication mode `API`, self-managed add-on bootstrap disabled, `general-purpose` node pool, elastic load balancing and block storage enabled
- Access entry and `AmazonEKSClusterAdminPolicy` association for one IAM principal (`admin_arn`)

## File layout

```
versions.tf    terraform and provider settings
variables.tf   region, vpc_cidr, azs, cluster_name, cluster_version, admin_arn
main.tf        network module call
iam.tf         cluster and node roles, policy attachments (for_each)
eks.tf         cluster, access entry, access policy association
outputs.tf     cluster name and endpoint
```

## Usage

`terraform.tfvars` (not committed):

```hcl
admin_arn = "arn:aws:iam::<account>:user/<name>"   # aws sts get-caller-identity --query Arn --output text
```

```bash
terraform init
terraform plan          # 26 resources
terraform apply         # 10 to 15 minutes
```

Connect and watch Auto Mode scale from zero:

```bash
aws eks update-kubeconfig --name test_cluster --region eu-central-1
kubectl get nodes                      # empty: no pods, no nodes
kubectl run test --image=nginx
kubectl get nodes -w                   # a node joins after 1 to 2 minutes
kubectl get pods -o wide
kubectl delete pod test                # the node is removed a few minutes later
```

## Tear down

```bash
terraform destroy       # 10 minutes; the cluster is billed hourly
```

## Cost

Control plane 0.10 USD/h, NAT gateway about 0.05 USD/h, plus a small instance only while pods run. Roughly 0.20 USD/h; destroy the same day.

## Notes

- `authentication_mode = "API"` replaces the `aws-auth` ConfigMap: who can reach the cluster is defined with access entries in Terraform, not inside Kubernetes.
- `bootstrap_self_managed_addons = false` is required for Auto Mode; VPC CNI, CoreDNS and kube-proxy are managed by AWS.
- Node count is not configured anywhere. The embedded Karpenter reads pending pod requests and launches a matching instance. Limits (instance families, spot, max vCPU) are set later with a `NodePool` manifest on the Kubernetes side.
- `depends_on` on the cluster points at the policy attachment resources as a whole; a `for_each` resource is referenced without an index.