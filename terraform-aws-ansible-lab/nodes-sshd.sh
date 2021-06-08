sudo yum install -y python3 
sudo yum install -y ansible git 
sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sudo systemctl restart sshd.service
echo Node Configuration has been completed !