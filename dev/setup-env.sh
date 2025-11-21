#!/bin/bash

set -euo pipefail

PYTHON_VERSION=${PYTHON_VERSION:-}

if [[ "$PYTHON_VERSION" == "" ]]; then
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS=$ID
    OS_VERSION=$VERSION_ID
  else
    exit 1
  fi

  MAJOR_VERSION=$(echo "$OS_VERSION" | cut -d. -f1)

  if [[ "$OS" == "ubuntu" && "$MAJOR_VERSION" == "22" ]]; then
    PYTHON_VERSION="/usr/bin/python3.10"
  elif [[ "$OS" == "rocky" && "$MAJOR_VERSION" == "8" ]]; then
    PYTHON_VERSION="/usr/bin/python3.12" # use `sudo yum install python3.12` on Rocky Linux 8 to install this
  elif [[ "$OS" == "rocky" && "$MAJOR_VERSION" == "9" ]]; then
    PYTHON_VERSION="/usr/bin/python3.12"
  else
    echo "Unsupported OS version: $OS $MAJOR_VERSION"
    exit 1
  fi
fi

if [[ ! -x venv/bin/python ]] || \
   [[ "$($PYTHON_VERSION -V 2>&1)" != "$(venv/bin/python -V 2>&1)" ]]; then
    rm -rf venv
    $PYTHON_VERSION -m venv venv
fi

# shellcheck disable=SC1091
. venv/bin/activate
pip install -U pip
pip install -r requirements.txt
ansible --version
# Install or update ansible dependencies ...
ansible-galaxy role install -fr requirements.yml -p ansible/roles
ansible-galaxy collection install -fr requirements.yml -p ansible/collections
cp requirements.yml requirements.yml.last
