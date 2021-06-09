# Ansible Lab - Using Terraform and AWS

*Warning: this is still in-progress and do not use*

Also check **[Terraform IaC Examples ](https://github.com/ginigangadharan/terraform-iac-usecases)**.

## Introduction

Terraform will provision below resources and take note on details.

- 1x ec2 instance for Ansible Engine.
- 2x ec2 instances fro Ansible managed nodes.
- We are using `Amazon Linux 2 AMI (HVM), SSD Volume Type` (`ami-02f26adf094f51167`); you can create with other AMI's as well by changing the AMI details in `variables.tf` (Consider adjusting the installation commands if you are changing the AMI or OS)
- Default `region = "ap-southeast-1"` (**Singapore**), change this in `main.tf` if needed.
- A new Security Group will be created as `ansible-lab-security-group` (which will be destroyed when you do `terraform destroy` together with all other resources)
- All Nodes will be configured with ssh access.
- All Nodes will be installed with ansible, git, vim and other necessary packages.
- Uncomment `# sudo yum update -y` in `user-data.sh` if you need to update the nodes with latest updates.

# How to use this repository
## Installing Terraform

If you haven't yet, [Download](https://www.terraform.io/downloads.html) and [Install](https://learn.hashicorp.com/tutorials/terraform/install-cli) Terraform.

## Configure AWS Credential

Refer [AWS CLI Configuration Guide](https://github.com/ginigangadharan/vagrant-iac-usecases#aws-setup) for details.

## Create SSH Keys to Access the ec2 instances

If you have existing keys, you can use that; otherwise create new ssh keys.

- ***Warning**: Please remember to not to overwrite the existing ssh key pair files; use a new file name if you want to keep the old keys.*
- If you are using any key files other than `~/.ssh/id_rsa`, then remember to update the same in `variables.tf` as well.

```shell
$ ssh-keygen
```

## Clone the Repository and Spin up

```shell
$ git clone https://github.com/ginigangadharan/terraform-iac-usecases
$ cd terraform-aws-ansible-lab

## init terraform
$ terraform init

## verify the resource details before apply
$ terraform plan

## Apply configuration - This step will spin up all necessary resources in your AWS Account
$ terraform apply
.
.
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_key_pair.ec2loginkey: Creating...
aws_security_group.ansible_access: Creating...
.
.
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

ansible-engine = 13.250.12.72
ansible-node-1 = 13.212.78.180
ansible-node-2 = 54.254.68.95
```

## How to Access the Lab ?

Terraform will show you the `Public IP` of `ansible-engine` instance and you can access the ansible-engine using that IP. 

- Host: Public IP of `ansible-engine`
- Username: `devops`
- Password: `devops`
- You can also access other nodes using same username and password
- `ansible-engine` to `ansible-nodes` ssh connection is already setup using password in `inventory` file.

```shell
$ ssh devops@IP_ADDRESS

## check ansible version
[devops@ansible-engine ~]$ ansible --version
ansible 2.9.21
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/home/devops/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/site-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.18 (default, Feb 18 2021, 06:07:59) [GCC 7.3.1 20180712 (Red Hat 7.3.1-12)]
```



## Once you are done with lab/tests/learning destroy resources

```shell
$ terraform destroy
```

## Appendix

### Use `local-exec` if you have Ansible installed locally

If you are using Linux/Mac machine and ansible is available locally, then you an use below method for executing Terraform provisioner. (Current configuration is to execute ansible playbook to execute from `ansible-engine node` itself.)

```json
  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.public_ip},'  engine-config.yaml"
  }
```  