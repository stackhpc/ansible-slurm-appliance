#!/bin/bash

set -eux

# Workaround for: objc[3705]: +[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called.
# in CI
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

echo "Activating environment"

set +u
. venv/bin/activate
set -u

. environments/vagrant-example/activate

echo "Running adhoc/hpctests.yml"

ansible-playbook -vv ansible/adhoc/hpctests.yml
