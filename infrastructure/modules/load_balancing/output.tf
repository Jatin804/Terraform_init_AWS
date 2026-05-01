output "alb_dns_name" {
  value       = aws_lb.aws_main_alb.dns_name
  description = "The DNS URL of the Application Load Balancer"
}