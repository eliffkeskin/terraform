# vpc-alb

Two-tier network on AWS written with raw Terraform resources (no modules): an Application Load Balancer in public subnets forwarding to an nginx EC2 instance in a private subnet, with outbound internet through a NAT gateway.

## Architecture

```
Internet
   |
 [IGW]
   |
 VPC 10.0.0.0/16
   |-- public  10.0.0.0/24  (eu-central-1a)  ALB node, NAT gateway
   |-- public  10.0.1.0/24  (eu-central-1b)  ALB node
   |-- private 10.0.10.0/24 (eu-central-1a)  EC2 (nginx), no public IP
   |-- private 10.0.11.0/24 (eu-central-1b)
```

Traffic in: client -> ALB (port 80) -> target group -> EC2:80.
Traffic out: EC2 -> private route table -> NAT gateway -> IGW.

## What it creates

- VPC, 2 public and 2 private subnets across two AZs (`count` + `cidrsubnet`)
- Internet Gateway, public route table and associations
- Elastic IP, NAT gateway in the first public subnet, private route table and associations
- Two security groups: `alb-sg` (80 from anywhere) and `web-sg` (80 only from `alb-sg`, no SSH)
- t3.micro EC2 instance (Ubuntu 24.04, Canonical AMI) in a private subnet, nginx installed via `user_data`
- Application Load Balancer, target group, listener on port 80

## File layout

```
main.tf              root: calls the two modules
variables.tf         vpc_cidr, azs, instance_type
outputs.tf           ALB URL
versions.tf          terraform and provider settings
modules/network/     VPC, subnets, IGW, NAT, route tables (outputs: vpc_id, subnet ids)
modules/web/         security groups, EC2, ALB, target group, listener (output: alb_dns_name)
```

## Usage

```bash
terraform init
terraform plan
terraform apply
curl "$(terraform output -raw url)"
```

Allow 2 to 3 minutes after apply for the instance to boot, install nginx and pass the ALB health check.

## Cost

NAT gateway, ALB and the Elastic IP are billed hourly (roughly 2 USD per day combined). Destroy when done:

```bash
terraform destroy
```

## Things that broke while building this

- Swapping CIDR blocks between existing subnets cannot be applied in place; Terraform ends up in a partial destroy/create deadlock. Fixed with a full destroy and re-apply.
- `aws_route_table_association` accepts either `subnet_id` or `gateway_id`, not both. The IGW belongs in the route table's `route` block.
- ALB returned a timeout until the listener was added, then 502 until the backend became healthy. Timeout means the request never reached a listener; 502 means the ALB reached the target group but got no valid response.
- The instance booted before the NAT gateway was available, so `user_data` failed to reach apt and nginx was never installed. Fixed with `depends_on = [aws_nat_gateway, aws_route_table_association.private]` on the instance and `terraform apply -replace=aws_instance.web`.
- Refactored v1 (flat resources) into two local modules. Renaming a resource inside a module
  would normally force a replacement; a `moved` block keeps the state entry and results in
  "No changes". Left in place here as a reference.
- Module-level `depends_on` defers every data source in that module to apply time whenever the
  upstream module has a pending change, which turned a harmless route table update into an
  instance replacement (AMI became "known after apply"). Known issue, to be fixed by passing
  dependencies through outputs instead.