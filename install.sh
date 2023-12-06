#!/bin/bash

set -e

script_name="install.sh"
domain=$1
orgname=$2
unit_file_location=/lib/systemd/system/cagent.service

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

function create_unit_file() {
    printf "
[Unit]
Description=Python App Service
After=multi-user.target

[Service]
Type=simple
WorkingDirectory=/home/admin/
ExecStart=/usr/bin/python3 /home/admin/app/app.py
User=admin

[Install]
WantedBy=multi-user.target" > $unit_file_location
}

check_args

eula_msg

read -p "Do you accept the EULA?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
else
    echo "Install of agent aborted, user must accept EULA"
fi