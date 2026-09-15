provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.19.0"
    name = "web-vpc"
    cidr = "10.0.0.0/16"
    azs = ["eu-central-1a"]
    public_subnets = ["10.0.10.0/24"]
    enable_dns_hostnames = true
    
}

resource "aws_security_group" "web-sg" {
    name = "web-sg"
    description = "Web security group"
    vpc_id = module.vpc.vpc_id
    
    /*
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    */
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.my_ip}/32"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "web-sg"
    }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  subnet_id = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  user_data = file("user_data.sh")

  tags = {
    Name = var.instance_name
  }

  
}

