# output the bastion host IP address
output "bastion_ip_address" {
  value =aws_instance.bastion.public_ip
}

# output the DNS URL of the loadbalancer
output "jenkins_master_elb" {
  value = aws_elb.jenkins_elb.dns_name
}

# get the HTTPS DNS URL record
output "jenkins_dns" {
  value = "https://${aws_route53_record.jenkins_master.name}"
}