# Create the Jenkins instance from the custom Jenkins AMI
# specify the custom AMI to use
data "aws_ami" "jenkins_master" {
  most_recent = true 
  owners = ["self"]

  filter {
    name = "name"
    values = ["jenkins-master-*"]
  }
}

# create the security group the master will use
resource "aws_security_group" "jenkins_master_sg" {
  name = "${var.name}-${var.environment_type}-jenkins_master_sg"
  description = "Allow traffic for SSH and port 8080"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.sg_bastion.id]
  }

  ingress {
    description = "ELB Traffic, port 8080"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = [aws_security_group.elb_jenkins_sg.id]
    cidr_blocks = [var.vpc_address_space]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-jenkins-master-sg" }))
}

# create the instance from the AMI
resource "aws_instance" "jenkins_master" {
  ami = data.aws_ami.jenkins_master.id
  instance_type = var.jenkins_master_instance_type
  key_name = aws_key_pair.sshkey_bastion.id
  vpc_security_group_ids = [aws_security_group.jenkins_master_sg.id]
  subnet_id = aws_subnet.private_subnet01.id

  root_block_device {
    volume_type = "gp3"
    volume_size = 25
    delete_on_termination = true
  }

  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-jenkins_master" }))
}