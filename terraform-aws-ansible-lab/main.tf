provider "aws" {
  region                  = "ap-southeast-1"
  ## if you want to mention the aws credential from different path, enable below line
  #shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "ansible"
  #version                 = ">=2.0"
}

resource "aws_key_pair" "ec2loginkey" {
  key_name   = "login-key"
  ## change here if you are using different key pair
  public_key = file(pathexpand(var.ssh_key_pair_pub)) 
}

## ================================ Ansible Node Instances ================================
resource "aws_instance" "ansible-node" {
  ami           = var.aws_ami_id #"ami-0cd31be676780afa7"
  instance_type = "t2.micro"
  key_name = aws_key_pair.ec2loginkey.key_name
  count = var.ansible_node_count

  ## If you are creating Instances in a VPC, use vpc_security_group_ids instead.
  security_groups = ["ansible-lab-security-group"]

  ## Install EPEL Repo
  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install -y epel",
    ]
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))      
      host = self.public_ip
    }
  }

  ## basic setup on ansible node 
  provisioner "remote-exec" {
    script = "nodes-sshd.sh"
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))      
      host = self.public_ip
    }
  }

  ## copy inventory
  provisioner "remote-exec" {
    inline = [
      #"puppet apply",
      "echo '[ansible]' >> /home/ec2-user/inventory",
      "echo 'ansible-engine ansible_host=${aws_instance.ansible-engine.private_dns} ansible_connection=local' >> /home/ec2-user/inventory",
    ]
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))      
      host = self.public_ip
    }
  }

  ## copy ansible.cfg
  provisioner "file" {
    source      = "ansible.cfg"
    destination = "/home/ec2-user/ansible.cfg"
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))      
      host = self.public_ip
    }
  }

  ## copy engine-config.yaml
  provisioner "file" {
    source      = "engine-config.yaml"
    destination = "/home/ec2-user/engine-config.yaml"
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))      
      host = self.public_ip
    }
  }

  ## Execute Ansible Playbook
  provisioner "remote-exec" {
    inline = [
      "ansible-playbook engine-config.yaml -l ansible-engine",
    ]
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))      
      host = self.public_ip
    }
  }
  #provisioner "local-exec" {
  #  command = "ansible-playbook -i '${self.public_ip},'  engine-config.yaml"
  #}

  tags = {
    Name = "ansible-node-${count.index}"
  }
}

## ================================ Ansible Engine Instance ================================================
resource "aws_instance" "ansible-engine" {
  ami           = var.aws_ami_id #"ami-0cd31be676780afa7"
  instance_type = "t2.micro"
  key_name = aws_key_pair.ec2loginkey.key_name

  ## If you are creating Instances in a VPC, use vpc_security_group_ids instead.
  security_groups = ["ansible-lab-security-group"]


  ## Install EPEL Repo
  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install -y epel",
    ]
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))      
      host = self.public_ip
    }
  }

  ## basic setup on ansible node 
  provisioner "remote-exec" {
    script = "nodes-sshd.sh"
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))      
      host = self.public_ip
    }
  }

  ## copy inventory
  provisioner "remote-exec" {
    inline = [
      #"puppet apply",
      "echo '[ansible]' >> /home/ec2-user/inventory",
      "echo 'ansible-engine ansible_host=${aws_instance.ansible-engine.private_dns} ansible_connection=local' >> /home/ec2-user/inventory",
    ]
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))      
      host = self.public_ip
    }
  }

  ## copy ansible.cfg
  provisioner "file" {
    source      = "ansible.cfg"
    destination = "/home/ec2-user/ansible.cfg"
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))      
      host = self.public_ip
    }
  }

  ## copy engine-config.yaml
  provisioner "file" {
    source      = "engine-config.yaml"
    destination = "/home/ec2-user/engine-config.yaml"
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))      
      host = self.public_ip
    }
  }

  ## Execute Ansible Playbook
  provisioner "remote-exec" {
    inline = [
      "ansible-playbook engine-config.yaml -l ansible-engine",
    ]
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))      
      host = self.public_ip
    }
  }
  #provisioner "local-exec" {
  #  command = "ansible-playbook -i '${self.public_ip},'  engine-config.yaml"
  #}

  tags = {
    Name = "ansible-engine"
  }

  depends_on = [
    aws_instance.ansible-nodes,
  ]
}

output "ansible-engine" {
  #value = file("${path.module}/id_rsa.pub") #aws_key_pair.ec2loginkey.public_key
  #value = file(pathexpand("~/.ssh/id_rsa.pub")) 
  value = aws_instance.ansible-engine.private_dns
}

output "ansible-node-1" {
  #value = file("${path.module}/id_rsa.pub") #aws_key_pair.ec2loginkey.public_key
  #value = file(pathexpand("~/.ssh/id_rsa.pub")) 
  value = aws_instance.ansible-node[0].private_dns
}