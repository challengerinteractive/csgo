#/bin/bash 
sudo mkdir -p /var/lib/docker 
sudo mkfs -t ext4 /dev/nvme1n1
sudo mount /dev/nvme1n1 /var/lib/docker 
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common python3-pip
sudo pip3 install awscli
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce
sudo usermod -aG docker ubuntu
sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
