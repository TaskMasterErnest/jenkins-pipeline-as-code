# Jenkins-with-Packer Template

- In this repo are the scripts to use to provision an Amazon Linux machine image to house Jenkins.
- They are separated into the scripts to use for the master Jenkins server and the worker Jenkins servers.
- I have written them in the `.pkr.hcl` extension and in YAML but it can be written in JSON too.
- You need to have [Packer](https://developer.hashicorp.com/packer/downloads) installed on the local machine and [AWS CLI](https://aws.amazon.com/cli/) installed and configured. ( Click on the names to go the respective documentation ).


## Master Jenkins AMI Configuration
- In this configuration are the following scripts:
  - a `template.pkr.hcl` file with the code to build the AMI on AWS.
  - a `setup.sh` script with code to install the needed software to effectively run Jenkins on the AMI; Java, Git, SSH and Jenkins.
  - a `/config` directory that contains scripts to install the relevant Jenkins plugins.
  - a `/scripts` directory with Groovy scripts to configure the Jenkins server.