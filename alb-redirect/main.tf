
terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  # The latest version of Terragrunt (v0.19.0 and above) requires Terraform 0.12.0 or above.
  required_version = "~> 0.12"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      version = "~> 2.70"
    }
  }
}

resource "aws_lb" "myalb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
#   security_groups    = var.security_groups
  subnets            = var.subnets
}

resource "aws_lb_listener" "listener443" {
  load_balancer_arn =   aws_lb.myalb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "redirect"

    redirect {
      host        = var.redirect_to_host
      port        = var.redirect_to_port
      path        = var.redirect_to_path      
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_certificate" "additional_certs" {

  for_each = var.additional_certificates
  listener_arn    = aws_lb_listener.listener443.arn
  certificate_arn = each.key
}

resource "aws_lb_listener" "listener80" {
  load_balancer_arn =   aws_lb.myalb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      host        = var.redirect_to_host
      port        = var.redirect_to_port
      path        = var.redirect_to_path      
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
# resource "aws_lb_listener_rule" "listen" {
#   listener_arn = aws_lb_listener.mylistener.arn
#   priority     = 100

#   action {
#     type             = "redirect"
#     redirect {
#       host        = var.redirect_to_host
#       port        = var.redirect_to_port
#       path        = var.redirect_to_path     
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }    
#   }
#   condition {
#     host_header {
#       values = var.host_header_values
#     }
#   }
# }
