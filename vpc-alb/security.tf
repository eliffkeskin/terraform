resource "aws_security_group" "alb-sg" {
    name = "alb-sg"
    description = "ALB security group"
    vpc_id = aws_vpc.main.id
    
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "alb-sg"
    }
}

resource "aws_security_group" "web-sg" {
    name = "web-sg"
    description = "Web security group"
    vpc_id = aws_vpc.main.id
    
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.alb-sg.id]
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