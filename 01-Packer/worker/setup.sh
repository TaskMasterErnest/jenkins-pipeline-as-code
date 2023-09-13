#!/bin/bash

echo ">>>>>>>>>> Install git"
sudo dnf install -y git
echo ">>>>>>>>>> Install Java"
sudo dnf install java-11-amazon-corretto -y
echo ">>>>>>>>>> Install Docker"
sudo dnf install docker -y
echo ">>>>>>>>>> Configuring Docker"
sudo usermod -aG docker ec2-user
sudo systemctl enable docker