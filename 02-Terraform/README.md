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
- the `02-bastion.tf` file contains Terraform code to configure the Bastion host to which we can connect and talk to the instances in the private subnets.