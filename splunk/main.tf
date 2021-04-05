#inspired by https://github.com/ChiefRiver/AWSSplunkInstance/blob/master/main.tf

terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  required_version = "~> 0.13"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

#Create the Instance SG
resource "aws_security_group" "splunk_sg" {
  name   = "splunk_sg"
  vpc_id = var.vpc_id

  ingress {
    description     = "ingress from bastion sg"
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    security_groups = [var.bastion_security_group_id]
  }
  ingress {
    description = "splunk index input"
    protocol    = "tcp"
    from_port   = 9997
    to_port     = 9997
    self        = true
  }
  ingress {
    description = "peer access to SQL"
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = var.peer_cidr_blocks
  }
  # results in cycle... before, this was added to this sg by virtue of it being added to the lb sg.
  # ingress {
  #   description = "ingress from ALB"
  #   protocol = "tcp"
  #   from_port = 443
  #   to_port = 443
  #   security_groups = [aws_security_group.splunk_lb_sg.id]
  # } 
  egress {
    description = "egress on port 80"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "egress on port 443"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "splunk index input"
    protocol    = "tcp"
    from_port   = 9997
    to_port     = 9997
    self        = true
  }
  egress {
    description = "peer access to SQL"
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = var.peer_cidr_blocks
  }
  egress {
    description = "splunk license server"
    protocol = "tcp"
    from_port = 8089
    to_port = 8089
    cidr_blocks = var.splunk_license_server_cidr
  }  
}

# allow web, but only from load balancer security group
resource "aws_security_group_rule" "lb_to_instance" {
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.splunk_sg.id
  source_security_group_id = aws_security_group.splunk_lb_sg.id
  to_port                  = 443
  type                     = "ingress"
}

# Create the web LB SG. 
resource "aws_security_group" "splunk_lb_sg" {
  name   = "splunk_lb_sg"
  vpc_id = var.vpc_id

  ingress {
    description = "external to LB for select IPs"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = var.elb_access_cidr
  }
  egress {
    description = "LB to splunk search head on port 443"
    protocol = "tcp"
    from_port = 443
    to_port = 443
    security_groups = [aws_security_group.splunk_sg.id]
  }

}


resource "aws_lb" "splunk_web" {
  name               = "splunk-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.splunk_lb_sg.id]
  subnets            = var.elb_subnets

  tags = {
    Name = "splunk-elb"
  }
}
resource "aws_lb_target_group" "splunk_web" {
  name     = "splunk-search-head-https"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    path    = "/"
    matcher = "200-399" # anything in 2xx or 3xx... TODO. find a better path to check
  }
}

resource "aws_lb_listener" "splunk_web" {
  load_balancer_arn = aws_lb.splunk_web.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.splunk_web.arn
  }
}

resource "aws_lb_target_group_attachment" "splunk" {

  target_group_arn = aws_lb_target_group.splunk_web.arn
  target_id        = aws_instance.prod_search_head.id
  port             = 443
}

resource "aws_route53_record" "www" {
  zone_id = var.route53_zone_id
  name    = "splunk.fcbh.org"
  type    = "A"

  alias {
    name                   = aws_lb.splunk_web.dns_name
    zone_id                = aws_lb.splunk_web.zone_id
    evaluate_target_health = true
  }
}

///////////////////////////////////
#Splunk Enterprise AMI
resource "aws_instance" "prod_search_head" {
  ami                    = var.splunk_ami
  instance_type          = var.prod_search_head_instance_type
  vpc_security_group_ids = [aws_security_group.splunk_sg.id]
  key_name               = var.ssh_pub_key_name
  subnet_id              = var.splunk_subnet_id

  tags = {
    Name = "Splunk Prod Search Head"
  }

  ebs_block_device {
    delete_on_termination = false
    encrypted             = false
    device_name           = "/dev/sdf"
    iops                  = 9000
    snapshot_id           = "snap-xxx" # associated with "vol-01e8af24c7a98bdf4"
    volume_size           = 3000
    volume_type           = "gp2"
  }

  user_data = <<EOF
		#! /bin/bash
    yum install httpd mod_ssl -y  
    sed -i '/<VirtualHost _default_:443>/a SSLProxyEngine on' /etc/httpd/conf.d/ssl.conf
    sed -i '/<VirtualHost _default_:443>/a SSLProxyVerify none' /etc/httpd/conf.d/ssl.conf
    sed -i '/<VirtualHost _default_:443>/a SSLProxyCheckPeerCN off' /etc/httpd/conf.d/ssl.conf
    sed -i '/<VirtualHost _default_:443>/a SSLProxyCheckPeerName off' /etc/httpd/conf.d/ssl.conf
    sed -i '/<VirtualHost _default_:443>/a ProxyPass \/ https:\/\/127.0.0.1:8000\/' /etc/httpd/conf.d/ssl.conf
    sed -i '/<VirtualHost _default_:443>/a ProxyPassReverse \/ https:\/\/127.0.0.1:8000\/' /etc/httpd/conf.d/ssl.conf
    chkconfig httpd on
    service httpd restart

    runuser -u splunk -g splunk -- mkdir -p /opt/splunk/etc/system/local/
    runuser -u splunk -g splunk -- echo "[settings]" >> /opt/splunk/etc/system/local/web.conf
    runuser -u splunk -g splunk -- echo "enableSplunkWebSSL = 1" >> /opt/splunk/etc/system/local/web.conf

    yum install git
    yum update -y
	EOF
}

resource "aws_instance" "forwarder" {
  ami                    = var.splunk_ami
  instance_type          = var.forwarder_instance_type
  iam_instance_profile   = var.forwarder_iam_instance_profile
  vpc_security_group_ids = [aws_security_group.splunk_sg.id]
  ebs_optimized          = true
  key_name               = var.ssh_pub_key_name
  subnet_id              = var.splunk_subnet_id

  tags = {
    Name = "Splunk Forwarder"
  }
}