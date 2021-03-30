# Vagrant-Example cluster

Provisions an environment using vagrant - this is used by Gitlab CI too.

This README is supplimentary to the main readme at `<repo_root>/README.md` so only differences/additional information is noted here. Paths are relative to this environment unless otherwise noted.

## Pre-requisites
No additional comments.

## Installation on deployment host
See main README and then additionally install Vagrant and a provider. For CentOS 8, you can install Vagrant + VirtualBox using:

    sudo dnf install https://releases.hashicorp.com/vagrant/2.2.6/vagrant_2.2.6_x86_64.rpm
    sudo dnf config-manager --add-repo=https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo
    sudo yum install VirtualBox-6.0

(Note that each Vagrant version only supports a subset of VirtualBox releases.)

## Overview of directory structure
See main README, plus:
- The vagrant configuration is contained in the `vagrant/` directory.
- Scripts are provided in the `<repo_root>dev/` directory to provision and configure the environment.

## Creating a Slurm appliance

To provision and configure the appliance in the same way as the CI use:

    cd <repo root>
    dev/vagrant-provision-example.sh
    dev/vagrant-example-configure.sh

To debug failures, activate the venv and environment and switch to the vagrant project directory:

    . venv/bin/activate
    . environments/vagrant-example/activate
    cd $APPLIANCES_ENVIRONMENT_ROOT/vagrant

(see the main README for an explanation of environment activation). Example vagrant commands are:
   
   vagrant status         # list vms
   vagrant ssh <hostname> # login
   vagrant destroy --parallel # destroy all VMs in parallel **without confirmation**
