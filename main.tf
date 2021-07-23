provider "aws" {
  region = "eu-west-2"
}

#------------------Security_Group-----------------------

resource "aws_security_group" "alb" {
  name        = "terraform_alb_security_group"
  description = "Terraform load balancer security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-alb-security-group"
  }
}
#------------------Application_Load_Balancer-----------------------

resource "aws_lb" "alb" {
  name               = "terraform-alb"
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb.id}"]
  subnets            = [var.subnet_a, var.subnet_b, var.subnet_c]
  count              = var.load_balancer_type == "alb" ? 1 : 0
  tags = {
    Name = "terraform-alb"
  }
}
#------------------Listener_for_ALB-------------------------------

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.web.arn
    type             = "forward"
  }
}
