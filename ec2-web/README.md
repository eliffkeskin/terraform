# ec2-web

Minimal Terraform project on AWS: a single Ubuntu EC2 instance running nginx in a public subnet, reachable over HTTP.

## What it creates

- VPC (10.0.0.0/16) with one public subnet, Internet Gateway and public route table (via `terraform-aws-modules/vpc`)
- Security group: port 80 open to the world, port 22 open only to your IP
- t3.micro EC2 instance (Ubuntu 24.04, latest Canonical AMI) with a public IP
- nginx installed at first boot through `user_data`, serving a static page

## Prerequisites

- Terraform >= 1.9
- AWS CLI configured with a profile that can create VPC and EC2 resources
- Region: eu-central-1 (change in `main.tf` if needed)

## Usage

Create `terraform.tfvars` with your public IP (not committed):

```hcl
my_ip = "1.2.3.4"   # curl ifconfig.me
```

Then:

```bash
terraform init
terraform plan
terraform apply
curl "$(terraform output -raw url)"
```

Expected output after 1 to 2 minutes (cloud-init needs time to install nginx):

```
hello from terraform
```

## Tear down

```bash
terraform destroy
```

## Notes

- Changing `user_data` or `associate_public_ip_address` forces the instance to be replaced.
- Removing the port 80 ingress rule and re-applying is a quick way to see an in-place security group update and the resulting timeout.
- State is local to this folder; remote state (S3 backend) is introduced in a later project.