# output the bastion host IP address
output "bastion_ip_address" {
  value =aws_instance.bastion.public_ip
}