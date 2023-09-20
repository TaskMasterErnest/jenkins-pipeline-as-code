# Deploying a High-Availability Jenkins Cluster with Terraform

In here, we will now use Terraform to do the following:
- automate the creation of the Jenkins master and worker instances from the AMIs
- create AWS resources that will enable the cluster to be highly available; Auto-Scaling Groups, a LoadBalancer and a Bastion host (I will add code for using an OpenVPN ami as a bastion, eventually) and the essential AWS resources needed to host a the application.

## CheckList
- [ ] Create AWS environment; VPC, Subnets, IGW, Route tables, NAT Gateway ... etc
- [ ] Setting up a self-healing Jenkins master
- [ ] Setting up the dynamically scaling Jenkins workers

## Setting Up the AWS Environment
To start deploying the Jenkins instances into AWS, we need to create a new Virtual Private Cloud aside the default one. This is to isolate the Jenkins instances from any workloads that might be deployed in the default or any other VPC.
I will now proceed to describe what is in each Terraform file:
- the `01-networking.tf` file contains code to set up Terraform with the AWS provider, create a new VPC, create four subnets (2 public, 2 private) and place them in pairs in two Availability Zones, an Internet gateway to route traffic to the internet, public and private route tables for each kind of subnet, a NAT gateway for the private subnets.
- the `02-bastion.tf` file contains Terraform code to configure the Bastion host to which we can connect and talk to the instances in the private subnets. It contains a specific AMI, an SSH key pair and a security group that allows SSH traffic into it making it ready for secure remote access to other instances in the VPC.
- the `03-jenkins_master.tf` file contains code that creates a security group for the Jenkins master instance, makes available the SSH port to the bastion host and takes ingress on port 8080 from anywhere, uses the Jenkins master AMI to provision the Jenkins master instance. An SSH key is added to the instance so that the Bastion can SSH into the master instance.
- the `04-elb.tf` file contains code to provision an Elastic Loadbalancer that accepts traffic on port 80 and forwards it to the Jenkins master instance on port 8080. 