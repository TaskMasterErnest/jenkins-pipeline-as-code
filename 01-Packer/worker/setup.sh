#!/bin/bash

echo ">>>>>>>>>> Install git"
sudo yum install -y git
echo ">>>>>>>>>> Install Java"
sudo yum install java-11-amazon-corretto -y
echo ">>>>>>>>>> Install Docker"
sudo yum install docker -y
echo ">>>>>>>>>> Configuring Docker"
sudo usermod -aG docker ec2-user
sudo systemctl enable docker