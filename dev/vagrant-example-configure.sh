#!/bin/bash

set -eux

echo "Activating environment"

set +u
. venv/bin/activate
set -u

. environments/vagrant-example/activate

echo "Running generate-passwords.yml"

ansible-playbook ansible/adhoc/generate-passwords.yml

echo "Running site.yml"

ansible-playbook ansible/site.yml
