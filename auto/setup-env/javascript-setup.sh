#!/bin/bash

# Install Node.js and npm
sudo apt-get install nodejs npm

# Install Visual Studio Code
sudo snap install --classic code

# Install Git
sudo apt-get install git

# Set up Git
read -p "Enter your name for Git: " git_name
read -p "Enter your email for Git: " git_email
git config --global user.name "$git_name"
git config --global user.email "$git_email"

# Install Yarn
read -p "Do you want to install Yarn? [y/N]: " install_yarn
if [[ $install_yarn =~ ^[Yy]$ ]]
then
  npm install -g yarn
fi

echo "JavaScript development environment set up successfully!"