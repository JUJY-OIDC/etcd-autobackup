#!/bin/bash

#======================= set env =======================================================
export USER_OCID=
export TENANCY_OCID=
export BUCKET_REGION=
export API_KEY_PATH=
export BUCKET_NAME=



#======================= install oci-cli ===============================================
curl -L -O https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh
chmod +x install.sh
# silent 모드로 설치 실행
./install.sh --accept-all-defaults

echo "::add-path::/home/runner/bin"
# alias 로 oci 명령어로 실행할 수 있도록 설정
alias oci='$HOME/bin/oci'
# 설치 확인
echo "######################"
echo "# oci version = $(oci --version) #"
echo "######################"



#======================= install expect ================================================
sudo apt-get install expect -y



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