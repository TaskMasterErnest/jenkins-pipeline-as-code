# In order to create the bastion; we need an EC2 instance, 
# an SSH key from the local and the security group it will use

# get the bastion AMI
data "aws_ami" "bastion" {
  most_recent = var.ami_most_recent
  owners = [var.ami_owners]

  filter {
    name = "name"
    values = [var.ami_filter_name]
  }

  filter {
    name = "virtualization-type"
    values = [var.ami_filter_virtualization_type]
  }
}

# create the SSH key pair to use
resource "aws_key_pair" "sshkey_bastion" {
  key_name = "bastion-management"
  public_key = file(var.public_key)
}

# create the security group for the bastion
resource "aws_security_group" "sg_bastion" {
  name = "${var.name}-${var.environment_type}-sg-bastion"
  description = "Allow SSH traffic into the Bastion host"
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-sg-bastion" }))

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create the instance the bastion will inhabit
resource "aws_instance" "bastion" {
  ami = data.aws_ami.bastion.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.sshkey_bastion.id
  vpc_security_group_ids = [aws_security_group.sg_bastion.id]
  subnet_id = aws_subnet.public_subnet01.id
  associate_public_ip_address = true

  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-bastion-host" }))
}