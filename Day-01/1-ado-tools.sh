Azure Cloud Platform:
User name: adminRay
Password: Rayees@123456


sudo apt update && apt install -y unzip jq net-tools
apt install openjdk-17-jdk -y
apt install maven -y && curl https://get.docker.com | bash
usermod -a -G docker adminRay

# aws cli install
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# azurecli ubuntu install
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az --version

# terraform.io and packer.io copy the link and install in /usr/local/bin

cd /usr/local/bin
wget https://releases.hashicorp.com/terraform/1.10.3/terraform_1.10.3_linux_amd64.zip
unzip

# packer.io
wget https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_amd64.zip
unzip

# document.ansible.com  Select ubuntu and download the file accordingly
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

cd /etc/ansible
cp ansible.cfg ansible.cfg_backup
ansible-config init --disabled >ansible.cfg
nano ansible.cfg

ctrl w  host_key_checking = False


cd /usr/local/bin
sudo apt-get install wget gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
trivy --version

reboot the system for configurations.


Agent pool name: AzureAgentPool

Azure personal access token: 

follow steps as shown to configure agent

tar zxvf vsts-agent-linux-x64-4.270.0.tar.gz

./config.sh

sudo ./svc.sh install adminRay

sudo ./svc.sh start