#!/bin/bash

set -e

script_name="install.sh"
domain=$1
orgname=$2
current_service=cagent

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

if [[ $($sudo_cmd ps --no-headers -o comm 1 2>&1) == "systemd" ]] && command -v systemctl 2>&1; then

    systemctl enable ${current_service}.service
    
    # Use systemd if systemctl binary exists and systemd is the init process
    restart_cmd="$sudo_cmd systemctl restart ${current_service}.service"
    stop_instructions="$sudo_cmd systemctl stop $current_service"
    start_instructions="$sudo_cmd systemctl start $current_service"

  elif /sbin/init --version 2>&1 | grep -q upstart; then
    
    # Try to detect Upstart, this works most of the times but still a best effort
    restart_cmd="$sudo_cmd stop $current_service || true ; sleep 2s ; $sudo_cmd start $current_service"
    stop_instructions="$sudo_cmd stop $current_service"
    start_instructions="$sudo_cmd start $current_service"
fi

eval "$restart_cmd"

printf "\033[32m  If you ever want to stop the agent, run:

      $stop_instructions

  And to run it again run:

      $start_instructions\033[0m\n\n"