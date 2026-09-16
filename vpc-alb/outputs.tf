output "alb-dns-name" {
    description = "DNS name of ALB"
    value = aws_lb.alb.dns_name
}