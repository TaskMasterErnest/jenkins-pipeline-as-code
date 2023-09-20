# Adding resources to build the Jenkins worker AMI
# the Jenkins worker are to be created in an AutoScaling Group
# use the Jenkins worker AMIs
data "aws_ami" "jenkins_worker" {
  most_recent = true 
  owners = ["self"]

  filter {
    name = "name"
    values = ["jenkins-worker-*"]
  }
}

# create a security group fro the Jenkins workers
resource "aws_security_group" "jenkins_worker_sg" {
  name = "${var.name}-${var.environment_type}-jenkins-worker-sg"
  description = "Allow SSH from Jenkins Master SG"
  vpc_id = aws_vpc.vpc.id 

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.jenkins_master_sg.id, aws_security_group.sg_bastion.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-jenkins-worker-sg" }))
}

# create a Jenkins user-data script that will be executed at boot time on each jenkins worker instance
data "template_file" "user_data_jenkins_worker" {
  template = "${file("scripts/join-cluster.tpl")}"

  vars = {
    jenkins_url = "http://${aws_instance.jenkins_master.private_ip}:8080"
    jenkins_username = var.jenkins_username
    jenkins_password = var.jenkins_password
    jenkins_credentials_id = var.jenkins_credentials_id
  }
}

# first step is to create a launch configuration:
resource "aws_launch_configuration" "jenkins_workers_launch_config" {
  name_prefix = "${var.name}-${var.environment_type}-launch_config"
  image_id = data.aws_ami.jenkins_worker.id
  instance_type = var.jenkins_worker_instance_type
  key_name = aws_key_pair.sshkey_bastion.id 
  security_groups = [aws_security_group.jenkins_worker_sg.id]
  user_data = data.template_file.user_data_jenkins_worker.rendered

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    delete_on_termination = false 
  }

  lifecycle {
    create_before_destroy = true
  }
}

# create the AutoScaling Group resource for the Jenkins workers
resource "aws_autoscaling_group" "jenkins_workers" {
  name = "${var.name}-${var.environment_type}-jenkins_workers-asg"
  launch_configuration = aws_launch_configuration.jenkins_workers_launch_config.name
  vpc_zone_identifier = [aws_subnet.private_subnet01.id, aws_subnet.private_subnet02.id]

  min_size = 2
  max_size = 10

  depends_on = [aws_instance.jenkins_master, aws_elb.jenkins_elb]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    value = "${var.name}-${var.environment_type}-jenkins-worker"
    propagate_at_launch   = true
  }
}