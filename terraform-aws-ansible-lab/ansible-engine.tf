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
      "echo '[nodes]' >> /home/ec2-user/inventory",
      "echo 'node1 ansible_host=${aws_instance.ansible-node-1.private_dns}' >> /home/ec2-user/inventory",
      "echo '[all:vars]' >> /home/ec2-user/inventory",
      "echo 'ansible_user=devops' >> /home/ec2-user/inventory",
      "echo 'ansible_password=devops' >> /home/ec2-user/inventory",
      "echo 'ansible_connection=ssh' >> /home/ec2-user/inventory",
      "echo 'ansible_ssh_private_key_file=/home/vagrant/.ssh/id_rsa' >> /home/ec2-user/inventory",
      "echo 'ansible_ssh_extra_args= \\' -o StrictHostKeyChecking=no -o PreferredAuthentications=password \\''' >> /home/ec2-user/inventory",
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

  #depends_on = [
  #aws_instance.ansible-node,
  #]
}