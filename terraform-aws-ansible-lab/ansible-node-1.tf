## ================================ Ansible Node Instances ================================
resource "aws_instance" "ansible-node-1" {
  ami           = var.aws_ami_id #"ami-0cd31be676780afa7"
  instance_type = "t2.micro"
  key_name = aws_key_pair.ec2loginkey.key_name
  #count = var.ansible_node_count

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

  # Add devops user
  provisioner "remote-exec" {
    inline = [
      #"puppet apply",
      "sudo useradd devops",
      "echo -e 'devops\ndevops' | passwd devops",
      "echo 'devops ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/devops",
      "sudo sed -i \"s/PasswordAuthentication no/PasswordAuthentication yes/g\" /etc/ssh/sshd_config",
      "sudo systemctl restart sshd.service",
    ]
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))      
      host = self.public_ip
    }
  }

  ## copy ansible.cfg
  #provisioner "file" {
  #  source      = "ansible.cfg"
  #  destination = "/home/ec2-user/ansible.cfg"
  #  connection {
  #    type = "ssh"
  #    user = "ec2-user"
  #    private_key = file(pathexpand(var.ssh_key_pair))      
  #    host = self.public_ip
  #  }
  #}

  ## copy engine-config.yaml
  #provisioner "file" {
  #  source      = "engine-config.yaml"
  #  destination = "/home/ec2-user/engine-config.yaml"
  #  connection {
  #    type = "ssh"
  #    user = "ec2-user"
  #    private_key = file(pathexpand(var.ssh_key_pair))      
  #    host = self.public_ip
  #  }
  #}

  ## Execute Ansible Playbook
  #provisioner "remote-exec" {
  #  inline = [
  #    "ansible-playbook engine-config.yaml -l ansible-engine",
  #  ]
  #  connection {
  #    type = "ssh"
  #    user = "ec2-user"
  #    private_key = file(pathexpand(var.ssh_key_pair))      
  #    host = self.public_ip
  #  }
  #}
  #provisioner "local-exec" {
  #  command = "ansible-playbook -i '${self.public_ip},'  engine-config.yaml"
  #}

  tags = {
    Name = "ansible-node" #-${count.index}"
  }
}
