#!/bin/bash

set -e

script_name="install.sh"
domain=$1
orgname=$2

function eula_msg(){
  printf "
If you are still having problems, please send an email to $support_email
with the contents of $logfile and any information you think would be
useful and we will do our very best to help you solve your problem.\n\n"
}

function check_args(){
    if [ -z "${domain}" ] || [ -z "${orgname}" ]; then
        echo "Script requires arguements, e.g. ${script_name} DOMAIN ORG_NAME"
        exit 2
    fi
}

function install_agent() {
    mkdir -p /opt/Cylerian
    cp -u cagent /opt/Cylerian
    cd /opt/Cylerian
    ./cagent install -d $domain --on $orgname
    cd -
}

check_args

eula_msg

read -p "Do you accept the EULA? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
else
    echo "Install of agent aborted, user must accept EULA to proceed with install"
    exit 0
fi

install_agent

# if systemd, enable restart
if [[ $(ps --no-headers -o comm 1) == *system* ]]; then
    systemctl enable cagent.service
fi