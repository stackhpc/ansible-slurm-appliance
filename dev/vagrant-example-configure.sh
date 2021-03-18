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

echo "Running generate-passwords.yml"

ansible-playbook ansible/adhoc/generate-passwords.yml

echo "Mocking openstack command for rebuild functionality"
# we don't need to mock the cloud file as it only needs to exist
mkdir /tmp/vagrant-example
cat > /tmp/vagrant-example/openstack <<EOL
#!/usr/bin/bash
echo "fake openstack command"
EOL
chmod u+x /tmp/vagrant-example/openstack
PATH=/tmp/vagrant-example:$PATH

echo "Running site.yml"

ansible-playbook -vvvv ansible/site.yml -e "openhpc_rebuild_clouds=/tmp/vagrant-example/openstack"
