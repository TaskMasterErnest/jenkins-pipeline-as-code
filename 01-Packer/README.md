# Jenkins-with-Packer Template

- In this repo are the scripts to use to provision an Amazon Linux machine image to house Jenkins.
- They are separated into the scripts to use for the master Jenkins server and the worker Jenkins servers.
- I have written them in the `.pkr.hcl` extension and in YAML but it can be written in JSON too.
- You need to have [Packer](https://developer.hashicorp.com/packer/downloads) installed on the local machine and [AWS CLI](https://aws.amazon.com/cli/) installed and configured. ( Click on the names to go the respective documentation ).

## CheckList
- [ ] Jenkins Master AMI Configuration
- [ ] Jenkins Worker AMI Configuration
- [ ] Tips
- [ ] Running the configurations


## Master Jenkins AMI Configuration
- In this configuration are the following scripts:
  - a `template.pkr.hcl` file with the code to build the AMI on AWS.
  - a `setup.sh` script with code to install the needed software to effectively run Jenkins on the AMI; Java, Git, SSH and Jenkins.
  - a `/config` directory that contains scripts to install the relevant Jenkins plugins.
  - a `/scripts` directory with Groovy scripts to configure the Jenkins server.

### Testing the Master Jenkins Server 
- In the `/standalone` directory are scripts to build and test the Jenkins master AMI and server instance.
  - build the AMI with `packer build /standalone/tempalte.pkr.hcl`. This utilizes the `setup.sh` script in the same directory to install and start Jenkins on the AMI.
  - launch an instance from the AMI after it is done building, in the AWS Console.
  - spell out a suitable name, I call mine `master`, and select/create a key pair to connect to the server; open the ports 8080 and 22 for the instance for Jenkins and SSH connection respectively.
  - after the instance is provisioned and running, you can connect to Jenkins running on it via the `<public-ip>:8080`way. SSH connections are done with the the key pair and its respective command.
  - to clear the AMI to save cost, select the AMI, go to 'Actions', select 'Deregister AMI' and confirm the deletion. The AMI is backed up with a snapshot, find 'Snapshots' under 'Elastic Block Store' and delete the respective block volume storing the data for the AMI.

### Configuring the Master Jenkins Server
- The focus is on the Groovy scripts in the `/scripts` directory. Jenkins is executed in a Java Virtual Machine (JVM) and the Groovy scripts are also executed in the same JVM as it, hence the Groovy scripts have direct full access to all the objects and resources of Jenkins. Thus, the Groovy scripts are used to interact with Jenkins, automate tasks and even extend the full functionality of Jenkins.
  - the `basic-security.groovy` script creates Jenkins user with Admin privileges. This script should be executed with caution and by Jenkins administrators (we are one of those!) with appropriate permissions.
  - the `csrf-protection.groovy` script utilizes a best practivce for Jenkins intallations. It provides CSRF protection to prevent malicious sites and/or attackers from executing actions on behalf of a logged-in user. The `DefaultCrumbIssuer` is responsible for generating and verifying CSRF protection tokens (called crumbs) in Jenkins.
  - the `disable-cli.groovy` script is used to disable the Jenkins CLI. The CLI allows users to interact with Jenkins remotely but it is a security concern, this script disables it and closes that window of concern.
  - the `disable-jnlp.groovy` script disables JNLP (Java Network Launch Protocol) and other non-encrypted connection protocols. The script aslso restricts the way the Jenkins agents can communicate with the Jenkins master, promoting a more secure and controlled communication method. The disabling may affect Jenkins agent connectivity and functionality.
  - the `node-agent.groovy` script is used to create SSH credentials that are used by Jenkins agents that connect to the master via SSH. It utilizes the Cloudbees Credentials Plugin and the SSH Slaves plugin to manage and store thes credentials.
  - the `skip-jenkins-setup.groovy` script is used to skip the setup of the Jenkins server after the scripts in the `/config` directory are run.


- The focus is on the scripts in the `/config` directory. These scripts are used to mainly install Jenkins plugins and set the environment for Jenkins to start work.
  - the `install-plugins.sh` script is for automating the installation and management of Jenkins plugins in a Jenkins instance
  - the `plugins.txt` file contains all the plugins to be installed on the Jenkins instance.
  - the `jenkins` file contains a set of settings for configuring the Jenkins Automation Server when it's installed and running as a service on a Unix-based system.


## Worker Jenkins AMI Configuration
- In this configuration, we have the following:
  - a `template.pkr.hcl` file that contains the code to build the Jenkins worker AMI.
  - a `setup.sh` script to configure the installation of Git, Java and Docker on the AMI.

- There are no other configurations needed to work on the Jenkins worker.  Docker is essential as the project needs to have Dockerized microservices which will have to be provisioned by some CI/CD pipelines.


## Tips
- In the `/master/scripts/basic-security.groovy` script, change the username and password to match your preference.
  - a handy command to generate a strong password is `openssl rand -base64 24`. It creates a strong password; with lowercase, special, uppercase, numbers. This particular command creates a 24-character long password, tweak the number to your preferred choice.
- generate a pair of SSH keys with the `ssh-keygen` command. This special key will be used in the `master/template.pkr.hcl` script to send a special private SSH key to the master Jenkins instance to be used for authenticating the workers.


## Running the Configurations
- Look through the master and worker configurations and set your own values.
- If you have successfully integrated you Access Key and Secret Access Key with the AWS CLI, Packer will pick them up by default when you spin it up.
- First, initialize the template with 
```bash
packer init master/template.pkr.hcl
```
- Then, validate the configuration template with
```bash
packer validate master/template.pkr.hcl
```
- Finally, build the AMI with the command
```bash
packer build master/template.pkr.hcl
```
- Wait as Packer builds the AMI on AWS, you can follow the progress on the output from the CLI.
- Check the `Testing the Master Jenkins Server` instructions on how to connect and eventually disconnect and clear up the AMIs when you are done.