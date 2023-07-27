#!/bin/bash

#======================= set env =======================================================
export USER_OCID=
export TENANCY_OCID=
export BUCKET_REGION=
export API_KEY_PATH=
export BUCKET_NAME=


# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}


#======================= install oci-cli ===============================================
# Check if OCI CLI is already installed
if command -v oci >/dev/null 2>&1; then
    echo "OCI CLI is already installed. Skipping installation."
else
    echo "OCI CLI not found. Installing..."
    # Install OCI CLI using the package manager (apt)
    sudo apt update
    curl -L -O https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh
    chmod +x install.sh
    # execute installation with silent mode
    ./install.sh --accept-all-defaults
    echo "::add-path::/home/runner/bin"
    # check installation
    echo "######################"
    echo "# oci version = $($HOME/bin/oci --version) #"
    echo "######################"
fi


#======================= install expect ================================================
# Check the package manager and install expect accordingly
if command -v expect >/dev/null 2>&1; then
    echo "expect is installed."
else
    echo "expect is not installed. Installing..."
    sudo apt update
    sudo apt install expect -y
fi

  
#======================= oci configure ; automation using expect =======================
expect -c "
spawn $HOME/bin/oci setup config

expect \"Enter a location for your config\"
send -- \"$HOME/.oci/config\r\"

expect \"Enter a user OCID\"
send -- \"$USER_OCID\r\"

expect \"Enter a tenancy OCID\"
send -- \"$TENANCY_OCID\r\"

expect \"Enter a region\"
send -- \"$BUCKET_REGION\r\"

expect \"Do you want to generate a new API Signing RSA key pair?\"
send -- \"n\r\"

expect \"Enter the location of your private key file\"
send -- \"$API_KEY_PATH\r\"

expect eof
"


#======================= create oci storage =============================================
$HOME/bin/oci os bucket create --compartment-id $TENANCY_OCID --name $BUCKET_NAME

# Check the response status
if [ $? -eq 0 ]; then
    echo "oci bucket '$BUCKET_NAME' created successfully."
else
    echo "Failed to create oci bucket '$BUCKET_NAME'. Please check the error message."
fi