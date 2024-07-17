#!/bin/bash

set -euo pipefail

if [[ ! -d "venv" ]]; then
    /usr/bin/python3 -m venv venv # use `sudo yum install python3` on Rocky Linux 9 to install this
fi
. venv/bin/activate
pip install -U pip
pip install -r requirements.txt
ansible --version
# Install or update ansible dependencies ...
ansible-galaxy role install -fr requirements.yml -p ansible/roles
ansible-galaxy collection install -fr requirements.yml -p ansible/collections
