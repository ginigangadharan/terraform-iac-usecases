# Ansible Lab - Using Terraform and AWS

*Warning: this is still in-progress and do not use*

Also check **[Terraform IaC Examples ](https://github.com/ginigangadharan/terraform-iac-usecases)**.

## Introduction

Terraform will provision below nodes

- 1x ec2 instance for Ansible Engine.
- 2x ec2 instances fro Ansible managed nodes.
- We are using `Amazon Linux 2 AMI (HVM), SSD Volume Type` (`ami-02f26adf094f51167`); you can create with other AMI's as well by changing the AMI details in `variables.tf` (Consider adjusting the installation commands if you are changing the AMI or OS)
- Default `region = "ap-southeast-1"` (**Singapore**), change this in `main.tf` if needed.
- A new Security Group will be created as `ansible-lab-security-group` (which will be destroyed when you do `terraform destroy` together with all other resources)
- All Nodes will be configured with ssh access.
- All Nodes will be installed with ansible, git and other necessary packages.


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

## Once you are done with lab/tests/learning destroy resources
$ terraform destroy
```

