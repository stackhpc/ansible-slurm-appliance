#!/bin/bash

set -euo pipefail

if [[ ! -d "venv" ]]; then
    /usr/bin/python3.8 -m venv venv # use `sudo yum install python38` on Rocky Linux 8 to install this
fi
. venv/bin/activate
pip install -U pip
pip install -r requirements.txt
ansible --version
# Install or update ansible dependencies ...
ansible-galaxy role install -fr requirements.yml -p ansible/roles
ansible-galaxy collection install -fr requirements.yml -p ansible/collections
