#!/bin/bash

set -euo pipefail

if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$ID
    OS_VERSION=$VERSION_ID
else
    exit 1
fi

MAJOR_VERSION=$(echo $OS_VERSION | cut -d. -f1)

PYTHON_VERSION=""

if [[ "$OS" == "ubuntu" && "$MAJOR_VERSION" == "22" ]]; then
    PYTHON_VERSION="/usr/bin/python3.10"
elif [[ "$OS" == "rocky" && "$MAJOR_VERSION" == "8" ]]; then
    PYTHON_VERSION="/usr/bin/python3.8" # use `sudo yum install python38` on Rocky Linux 8 to install this
elif [[ "$OS" == "rocky" && "$MAJOR_VERSION" == "9" ]]; then
    PYTHON_VERSION="/usr/bin/python3.9"
else
    echo "Unsupported OS version: $OS $MAJOR_VERSION"
    exit 1
fi

if [[ ! -d "venv" ]]; then
    $PYTHON_VERSION -m venv venv
fi

. venv/bin/activate
pip install -U pip
pip install -r requirements.txt
ansible --version
# Install or update ansible dependencies ...
ansible-galaxy role install -fr requirements.yml -p ansible/roles
ansible-galaxy collection install -fr requirements.yml -p ansible/collections
