#!/bin/bash

/usr/bin/python3.8 -m venv venv # use `sudo yum install python38` on Rocky Linux 8 to install this
. venv/bin/activate
pip install -U pip
pip install -r requirements.txt
ansible --version
# Install ansible dependencies ...
ansible-galaxy role install -r requirements.yml -p ansible/roles
ansible-galaxy collection install -r requirements.yml -p ansible/collections
