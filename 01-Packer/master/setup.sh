#!/bin/bash

echo ">>>>>>>>>> Install git"
sudo dnf install -y git

echo ">>>>>>>>>> Install Jenkins"
sudo dnf update
sudo dnf install java-11-amazon-corretto -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf install jenkins -y
sudo chkconfig jenkins on
sudo service jenkins start

# Wait for Jenkins to start (optional)
while ! sudo service jenkins status >/dev/null 2>&1; do
    sleep 5
done
echo ">>>>>>>>>>>>>>Jenkins has started ....<<<<<<<<<<<<<<<<<"

echo ">>>>>>>>>> Setup SSH key"
mkdir -p /var/lib/jenkins/.ssh
touch /var/lib/jenkins/.ssh/known_hosts
chown -R jenkins:jenkins /var/lib/jenkins/.ssh
chmod 700 /var/lib/jenkins/.ssh
mv /tmp/id_rsa /var/lib/jenkins/.ssh/id_rsa
chmod 600 /var/lib/jenkins/.ssh/id_rsa
chown -R jenkins:jenkins /var/lib/jenkins/.ssh/id_rsa


echo ">>>>>>>>>> Configure Jenkins"
mkdir -p /var/lib/jenkins/init.groovy.d
mv /tmp/scripts/*.groovy /var/lib/jenkins/init.groovy.d/
chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d
mv /tmp/config/jenkins /etc/sysconfig/jenkins
chmod +x /tmp/config/install-plugins.sh
mkdir -p /var/lib/jenkins/plugins

sudo chown -R jenkins:jenkins /var/lib/jenkins/plugins
sudo bash /tmp/config/install-plugins.sh

# Wait for plugin installation to finish
# echo "Waiting for plugin installation to finish..."
# while [ ! -f /var/lib/jenkins/plugins/locks/executors ]; do
#     sleep 10
# done

# Start Jenkins service after plugin installation
echo "Starting Jenkins service..."
sudo service jenkins restart
