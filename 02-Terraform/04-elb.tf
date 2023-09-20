# works in tandem with the Jenkins master instance
# in the Jenkins master instance's security group, add ingress from this ELB security group

# create the security group for the LoadBalancer resource
resource "aws_security_group" "elb_jenkins_sg" {
  name = "${var.name}-${var.environment_type}-elb-sg"
  description = "Allow HTTP traffic into VPC"
  vpc_id = aws_vpc.vpc.id 

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-elb-jenkins-sg" }))
}

# create the load balancer resource
resource "aws_elb" "jenkins_elb" {
  name = "${var.name}-${var.environment_type}-elb"
  subnets = [aws_subnet.public_subnet01.id, aws_subnet.public_subnet02.id]
  cross_zone_load_balancing = true 
  instances = [aws_instance.jenkins_master.id]
  security_groups = [aws_security_group.elb_jenkins_sg.id]

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = var.ssl_arn
  }

  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:8080"
    interval = 5
  }

  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-elb" }))
}

# create a Route 53 service
resource "aws_route53_record" "jenkins_master" {
  zone_id = var.hosted_zone_id
  name = "jenkins.${var.domain_name}"
  type = "A"

  alias {
    name = aws_elb.jenkins_elb.dns_name
    zone_id = aws_elb.jenkins_elb.zone_id
    evaluate_target_health = true
  }
}