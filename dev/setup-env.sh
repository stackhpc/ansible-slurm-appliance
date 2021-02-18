#!/bin/bash

python3 -m venv venv
. venv/bin/activate
pip install -U pip
pip install -r requirements.txt
# Install ansible dependencies ...
ansible-galaxy role install -r requirements.yml -p ansible/roles
ansible-galaxy collection install -r requirements.yml -p ansible/collections
