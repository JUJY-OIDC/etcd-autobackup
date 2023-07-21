#!/bin/bash

#======================= set ENV =================================================
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_REGION=""
export BUCKET_NAME="jujy-etcd-backup-$AWS_REGION"

#======================= install aws-cli =========================================
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


#======================= aws config =========================================
# directory 생성
mkdir -p ~/.aws

# configure 파일 생성
cat > ~/.aws/config << EOF
[default]
region = $AWS_REGION
output = json
EOF

# credential file 생성
cat > ~/.aws/credentials << EOF
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
EOF

# 권한 부여  
chmod 600 ~/.aws/config ~/.aws/credentials

#======================= create s3 =========================================
aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint=$AWS_REGION

# Check the response status
if [ $? -eq 0 ]; then
    echo "S3 bucket '$BUCKET_NAME' created successfully."
else
    echo "Failed to create S3 bucket '$BUCKET_NAME'. Please check the error message."
fi