# Environments

This folder contains the configuration for multiple different environments. Essentially
an environment is an ansible inventory, any files that may be referenced by that inventory,
and some code used to provision the infrastrcture. The code to provision the infrastructure
typically contains all the environment specific config. It must output an ansible inventory
that conforms to the structure we expect. Providing that the inventory conforms to this
structure, the ansible code will still be able to interface with that inventory.
This allows the ansible code to be decoupled from the code that deployed the infrastructure
and can therefore be tool and cloud agnostic i.e we don't care if you use tofu or ansible.

A pattern we use is to chain multiple ansible inventories to provide a crude form of inheritance. e.g

    common -> my_site -> production

Often the intermediate environments are not intended to be used directly,
but can mixin certain behaviors. We refer to these directories as `mixin` environments.
As an example, you might have a mixin which contained the configuration for infiniband:

    common -> infiniband -> my_site -> production

This would install the infiniband drivers and configure the node to use them.
This could either provide some sort of `hook` to run a custom playbook, or it could be
integrated into the toplevel `ansible` code, defining some sensible defaults, and
optionally defining the group membership.

## Directory structure

Overview of the directory structure. Please see `README.md` in the relevant sub-directory
for usage instructions for that component.

### common

Shared configuration for all environments. This is not
intended to be used as a standalone environment, hence the README does *not* detail
how to provision the infrastructure.

### skeleton

Skeleton directory that is used as a template to create a new environemnt.

## Defining an environment

To define an environment using cookiecutter:

    cookiecutter skeleton

This will present you with a series of questions which you must answer.
Once you have answered all questions, a new environment directory will
be created. The directory will be named according to the answer you gave
for `environment`.

Follow the README in the new directory to perform initial configuration.

## Activating environments

Typically, you need to activate an environment to be able to use it. You should then
be able to run the code in the `ansible` and `packer` toplevel directories. Activating
the environment will ensure that the ansible runs with the correct configuration for
that environment. See the `README.md` in the relevant subdirectory for more details.

## Enabling/Disabling services

Services are typically enabled/disabled by adding/removing a particular host or all
hosts from the associated group in the inventory. A pattern we use is to name the
ansible inventory `group` after the name of the `role` that configures it. The playbook
that runs this role targets hosts in that group. The `common` environment typically defines
all groups as the empty group. You must explicly opt-in and add hosts to these these groups
to configure that service.  For example, if you don't want to deploy and configure grafana,
you simply do not add any hosts to the `grafana` group in the inventory. This allows us to
have a shared ansible code base as we can define playbooks to configure all things,
but these playbooks end up not being run if no host is in the associated group.

See also:
    - `common/inventory/groups` for a list of all groups.

## Overriding configuration

The common environment defines a set of sensible defaults, which may or may not be applicable
to your target environment. It is sometimes necessary to overide a particular setting. As
inventories that are specified later in the chain take precedence, you can simply redefine
that variable in the more specific inventory.

Pull requests are welcome to split variables into smaller components to make it easier to partially override some elements of a larger data structure e.g making it possible to set `prometheus_node_exporter_collectors` instead of overriding the whole of the `prometheus_scrape_configs` dictionary.

### role variables

The pattern we use is that the role is run against an ansible inventory group matching
the name of the role. The role variables are defined as group variables in a file matching
the role name. These files are in placed in `group_vars/all` so that they have the lowest
precedence and more easily overridable. This convention makes it easier to find where the
varibles are set e.g role variables for the `stackhpc.nfs` role can be found in
`common/group_vars/all/nfs.yml`.

## Parent pointers

As the environments form a chain, a symlink pointing to the parent can be be created.

    `ln -s ../common/ parent`

This allows you to follow the chain more easily:

    # After following two parent pointers
    (venv-enroll) [stack@seed parent]$ pwd
    /home/stack/will/ansible-slurm-appliance/environments/production/parent/parent

    # Determing which element this path refers to
    (venv-enroll) [stack@seed parent]$ realpath .
    /home/stack/will/ansible-slurm-appliance/environments/common

This currently has no functional effect, but could be used in future to form the
chained list of inventories that is currently configured in `ansible.cfg`.
