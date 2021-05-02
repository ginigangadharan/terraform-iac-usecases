sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sudo systemctl restart sshd
sudo yum install python3 -y
sudo amazon-linux-extras install ansible2 -y
echo Done!