# aws load balancer 
resource "aws_lb" "aws_main_alb" {
    name = var.alb_name
    internal = false
    load_balancer_type = "application"
    security_groups = [var.alb_sg_id]
    subnets = var.public_subnet_ids

    tags = {
      Name = var.alb_name
    }   
}

# target port
resource "aws_lb_target_group" "alb_target_group" {
    name = "${var.alb_name}-flask" # FIX: Changed $() to ${}
    port = 30005
    protocol = "HTTP"
    vpc_id = var.vpc_id

    health_check {
      path = "/"
      port = "traffic-port"
      healthy_threshold = 3
      unhealthy_threshold = 3
      timeout = 5
      interval = 30
      matcher = "200"
    }
}

# listener
resource "aws_lb_listener" "alb_listener" {
    load_balancer_arn = aws_lb.aws_main_alb.arn
    port = 80
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.alb_target_group.arn
    }
}

# target group attachment
resource "aws_lb_target_group_attachment" "alb_target_attachment" {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    target_id = var.worker1_instance_id
    port = 30005
}