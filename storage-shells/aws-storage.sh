#!/bin/bash

# unzip 설치 
# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if unzip is not installed
if ! command_exists unzip; then
  echo "Unzip not found. Installing unzip..."
  
  # Check the package manager and install unzip accordingly
  if command_exists apt; then
    sudo apt update
    sudo apt install unzip -y
  elif command_exists yum; then
    sudo yum install unzip -y
  else
    echo "Package manager not found. You'll need to install unzip manually."
    exit 1
  fi
  
  echo "Unzip has been installed."
else
  echo "Unzip is already installed."
fi
# Check unzip version
echo "unzip version:"
unzip --version

# Function to check if the AWS CLI is installed
is_aws_cli_installed() {
    if command -v aws &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Check if AWS CLI is already installed
if is_aws_cli_installed; then
    echo "AWS CLI is already installed. Skipping installation."
else
    echo "AWS CLI not found. Installing..."
    # Install AWS CLI using the package manager (apt)
    sudo apt update
    sudo apt install -y awscli
fi

# Check unzip version
echo "aws version:"
aws --version