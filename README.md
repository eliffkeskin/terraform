# Terraform AWS Lab Projects

Hands-on Terraform projects on a personal AWS account. Each folder is a self-contained root module with its own state, README and a list of what broke while building it. Written by hand with raw provider resources where the goal is to learn the underlying AWS primitives, and with community modules where the goal is speed.

| Project | What it builds | Concepts covered |
|---|---|---|
| [ec2-web](./ec2-web) | Single public EC2 running nginx behind a security group | providers, variables and tfvars, data sources (AMI lookup), user_data, outputs, `terraform-aws-modules/vpc` |
| [vpc-alb](./vpc-alb) | Two-tier network: ALB in public subnets, nginx EC2 in a private subnet, NAT gateway for egress | raw VPC resources, `count` and `cidrsubnet`, route tables and associations, NAT and EIP, SG to SG references, ALB, target group and listener, `depends_on`, `-replace`, destroy ordering |

## Conventions

- One folder per project, `versions.tf` / `variables.tf` / `outputs.tf` plus topic files (`network.tf`, `security.tf`, `compute.tf`, `alb.tf`)
- Local state during the learning phase; remote state (S3 backend) is introduced in the next project
- Region `eu-central-1`, Free Tier instance types, everything destroyed after each session

## Requirements

- Terraform >= 1.9
- AWS CLI with a configured profile
- Run all commands from inside the project folder

## Roadmap

- [x] ec2-web: first apply, SG rules, user_data
- [x] vpc-alb: private subnet, NAT, ALB, health checks
- [ ] Refactor vpc-alb into `modules/network` and `modules/web`, S3 remote state with lockfile
- [ ] EKS cluster (Auto Mode) with Pod Identity, ArgoCD as an EKS capability
- [ ] GitHub Actions pipeline: fmt, validate, tflint, plan on PR, apply on main via OIDC