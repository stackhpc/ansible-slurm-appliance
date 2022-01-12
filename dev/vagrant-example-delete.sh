echo "Activating environment"

set +u
. venv/bin/activate
set -u

. environments/vagrant-example/activate

pushd $APPLIANCES_ENVIRONMENT_ROOT/vagrant
vagrant destroy --parallel
popd