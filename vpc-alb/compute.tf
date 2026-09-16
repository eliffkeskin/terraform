data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  subnet_id =aws_subnet.private[0].id

  user_data = file("user_data.sh")

  depends_on = [aws_nat_gateway.gw, aws_route_table_association.private]

  tags = {
    Name = var.instance_name
  }
}