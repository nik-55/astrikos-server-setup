#!/bin/bash

# Redirect stdout and stderr to both console and log file
exec > >(tee -i "setup.log") 2>&1

# region scripts/config.sh

# Constants
server_name="sand" # :)
backend_repo="nik-55/astrikos"
worker_repo="anand817/astrikos-worker"
thingsboard_repo="photon0205/thingsboard"
zip_frontend="https://drive.google.com/uc?export=download&id=1mRtRsDJ4TQoLV7s_XJvbYzCsQFhah2R5"

# Prompt user for github token
read -p "Enter github token: " github_token

if [ -z "$github_token" ]; then
    echo "Github token cannot be empty"
    exit 1
fi

# Enable sudo
sudo echo "sudo enabled"

# Prompt for confirmation to run the script
read -p "Do you want to run the script? (yes/no) " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Script execution cancelled"
    exit 1
fi
# endregion scripts/config.sh

# region scripts/install.sh
# Update and upgrade the system
sudo apt update -y
sudo apt upgrade -y
sudo apt-get update -y
sudo apt-get upgrade -y

# Utilities
sudo apt install coreutils -y
sudo apt install build-essential -y
sudo apt install wget -y
sudo apt install curl -y
sudo apt-get install unzip -y

# Snapd
sudo apt install snapd -y

# Git
sudo apt install git -y
git config --global user.name "$server_name"

# Docker
sudo apt-get update -y
sudo apt-get install ca-certificates -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Nginx
sudo apt install nginx -y

# Install Java 11 for Thingsboard
sudo apt install openjdk-11-jdk -y

# Install Conda
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh
~/miniconda3/bin/conda init bash

# endregion scripts/install.sh

# region scripts/shell.sh

# Beautify the bash prompt
ps1_var="PS1='\[\e[92m\]\u@${server_name}\[\e[0m\]:\[\e[91m\]\w\\$\[\e[0m\] '"
echo "" >> "$HOME/.bashrc"
echo "# Custom configuration" >> "$HOME/.bashrc"
echo "$ps1_var" >> "$HOME/.bashrc"

# endregion scripts/shell.sh

# region scripts/iam.sh
sudo usermod -aG docker $USER

# endregion scripts/iam.sh

# region scripts/verify.sh
# Verify Installation

# snapd
if ! command -v snap &> /dev/null; then
  echo "snapd is not installed"
fi

# git
if ! command -v git &> /dev/null; then
  echo "git is not installed"
fi

# docker
if ! command -v docker &> /dev/null; then
  echo "docker is not installed"
fi

# nginx
if ! command -v nginx &> /dev/null; then
  echo "nginx is not installed"
fi

# Java 11
if ! command -v java &> /dev/null; then
  echo "Java 11 is not installed"
fi

# Conda
if ! command -v conda &> /dev/null; then
  echo "Conda is not installed"
fi

# endregion scripts/verify.sh


echo "Setup script executed successfully"


# region project setup

# Thingsboard Frontend
curl -L -o temp.zip $zip_frontend
sudo unzip -o temp.zip -d /var/www/html
sudo rm -rf temp.zip
sudo mv /var/www/html/dist /var/www/html/astrikos


