#!/bin/bash

echo ">>>>>>>>>> Installing Amazon Linux extras"
amazon-linux-extras install epel -y

echo ">>>>>>>>>> Install git"
sudo dnf install -y git

echo ">>>>>>>>>> Install Jenkins"
sudo dnf update
sudo dnf install java-11-amazon-corretto -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf install jenkins -y
sudo chkconfig jenkins on

echo ">>>>>>>>>> Setup SSH key"
echo ".............................. 1"
mkdir -p /var/lib/jenkins/.ssh
echo ".............................. 2"
touch /var/lib/jenkins/.ssh/known_hosts
echo ".............................. 3"
chown -R jenkins:jenkins /var/lib/jenkins/.ssh
echo ".............................. 4"
chmod 700 /var/lib/jenkins/.ssh
echo ".............................. 5"
mv /tmp/id_jenkins_ssh /var/lib/jenkins/.ssh/id_jenkins_ssh
echo ".............................. 6"
chmod 600 /var/lib/jenkins/.ssh/id_jenkins_ssh
echo ".............................. 7"
chown -R jenkins:jenkins /var/lib/jenkins/.ssh/id_jenkins_ssh

echo ">>>>>>>>>> Configure Jenkins"
echo ".............................. 1"
mkdir -p /var/lib/jenkins/init.groovy.d
echo ".............................. 2"
mv /tmp/scripts/*.groovy /var/lib/jenkins/init.groovy.d/
echo ".............................. 3"
chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d
echo ".............................. 4"
mv /tmp/config/jenkins /etc/sysconfig/jenkins
echo ".............................. 5"
chmod +x /tmp/config/install-plugins.sh
echo ".............................. 6"
sudo chown -R jenkins:jenkins /var/lib/jenkins/plugins
echo ".............................. 7"
bash /tmp/config/install-plugins.sh
echo ".............................. 8"
service jenkins start