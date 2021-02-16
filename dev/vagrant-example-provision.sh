#!/bin/bash

echo "Activating environment"

set +u
. venv/bin/activate
set -u

. environments/vagrant-example/activate

pushd $APPLIANCES_ENVIRONMENT_ROOT/vagrant

echo "Installing plugins"

vagrant plugin install vagrant-hosts

echo "Provisioning servers"

vagrant up

echo "Generating inventory"

vagranttoansible | tee $APPLIANCES_ENVIRONMENT_ROOT/inventory/hosts

popd