# Operations

This page describes the commands required for common operations.

All subsequent sections assume that:

- Commands are run from the repository root, unless otherwise indicated by a `cd` command.
- An Ansible vault secret is configured.
- The correct private key is available to Ansible.
- Appropriate OpenStack credentials are available.
- Any non-appliance controlled infrastructure is available (e.g. networks, volumes, etc.).
- `$ENV` is your current, activated environment, as defined by e.g. `environments/production/`.
- `$SITE_ENV` is the base site-specific environment, as defined by `environments/site/`.
- A string `some/path/to/file.yml:myvar` defines a path relative to the repository root and an Ansible variable in that file.
- Configuration is generally common to all environments at a site, i.e. is made in `environments/$SITE_ENV` not `environments/$ENV`.

Review any [site-specific documentation](site/README.md) for more details on the above.

## Deploying a Cluster

This follows the same process as defined in the main [README.md](../README.md) for the default configuration.

Note that tags as defined in the various sub-playbooks defined in `ansible/` may be used to only run part of the tasks in `site.yml`.

## SSH to Cluster Nodes

This depends on how the cluster is accessed.

The script `dev/ansible-ssh` may generally be used to connect to a host specified by a `inventory_hostname` using the same connection details as Ansible. If this does not work:

- Instance IPs are normally defined in `ansible_host` variables in an inventory file `environments/$ENV/inventory/hosts{,.yml}`.
- The SSH user is defined by `ansible_user`, default is `rocky`. This may be overridden in your environment.
- If a jump host is required the user and address may be defined in the above inventory file.

## Modifying general Slurm.conf parameters

Parameters for [slurm.conf](https://slurm.schedmd.com/slurm.conf.html) can be added to an `openhpc_config_extra` mapping in `environments/$SITE_ENV/inventory/group_vars/all/openhpc.yml`.
Note that values in this mapping may be:

- A string, which will be inserted as-is.
- A list, which will be converted to a comma-separated string.

This allows specifying `slurm.conf` contents in an yaml-format Ansible-native way.

**NB:** The appliance provides some default values in `environments/common/inventory/group_vars/all/openhpc.yml:openhpc_config_default` which is combined with the above. The `enable_configless` flag in the `SlurmCtldParameters` key this sets must not be overridden - a validation step checks this has not happened.

See [Reconfiguring Slurm](#reconfiguring-slurm) to apply changes.

## Modifying Slurm Partition-specific Configuration

Modify the `openhpc_slurm_partitions` mapping usually in `environments/$SITE_ENV/inventory/group_vars/all/openhpc.yml` as described for [stackhpc.openhpc:slurmconf](https://github.com/stackhpc/ansible-role-openhpc#slurmconf) (note the relevant version of this role is defined in the `requirements.yml`)

Note an Ansible inventory group for the partition is required. This is generally auto-defined by a template in the OpenTofu configuration.

**NB:** `default:NO` must be set on all non-default partitions, otherwise the last defined partition will always be set as the default.

See [Reconfiguring Slurm](#reconfiguring-slurm) to apply changes.

## Adding an Additional Partition

This is a usually a two-step process:

- If new nodes are required, define a new node group by adding an entry to the `compute` mapping in `environments/$ENV/tofu/main.tf` assuming the default OpenTofu configuration:
  - The key is the partition name.
  - The value should be a mapping, with the parameters defined in `environments/$SITE_ENV/tofu/compute/variables.tf`, but in brief will need at least `flavor` (name) and `nodes` (a list of node name suffixes).
- Add a new partition to the partition configuration as described under [Modifying Slurm Partition-specific Configuration](#modifying-slurm-partition-specific-configuration).

Deploying the additional nodes and applying these changes requires rerunning both OpenTofu and the Ansible site.yml playbook - follow [Deploying a Cluster](#deploying-a-cluster).

## Adding Additional Packages

```
[squid:children]
# Hosts to run squid proxy
login
```

Note that many non-default roles include package installations from repositories which the appliance overwrites to point at snapshotted mirrors on a Pulp server (by default StackHPC's Ark server), which are
disabled during runtime to prevent Ark credentials from being leaked. To enable this functionality, you must therefore either:

- Create a site-specific fatimage (see [image build docs](image-build.md)) with the appropriate group added to the `inventory_groups` Packer variables.
- If you instead wish roles to perform their installations during runtime, deploy a site Pulp server and sync it with with mirrors of the snapshots from the upstream Ark server (see [Pulp docs](experimental/pulp.md)).

In both cases, Ark credentials will be required.

# Adding Additional Packages
By default, the following utility packages are installed during the StackHPC image build:

- htop
- nano
- screen
- tmux
- wget
- bind-utils
- net-tools
- postfix
- Git
- latest python version for system (3.6 for for Rocky 8.9 and 3.12 for Rocky 9.4)
- s-nail

Additional packages can be added during image builds by:

- adding the `extra_packages` group to the build `inventory_groups` (see
  [docs/image-build.md](./image-build.md))
- defining a list of packages in `appliances_extra_packages_other` in e.g.
  `environments/$SITE_ENV/inventory/group_vars/all/defaults.yml`. For example:

      ```yaml
          # environments/foo-base/inventory/group_vars/all/defaults.yml:
          appliances_extra_packages_other:
          - somepackage
          - anotherpackage
      ```

For packages which come from repositories mirrored by StackHPC's "Ark" Pulp server
(including rocky, EPEL and OpenHPC repositories), this will require either [Ark
credentials](./image-build.md)) or a [local Pulp mirror](./experimental/pulp.md)
to be configured. This includes rocky, EPEL and OpenHPC repos.

The packages available from the OpenHPC repos are described in Appendix E of
the OpenHPC installation guide (linked from the
[OpenHPC releases page](https://github.com/openhpc/ohpc/releases/)). Note
"user-facing" OpenHPC packages such as compilers, MPI libraries etc. include
corresponding `lmod` modules.

Packages _may_ also be installed during the site.yml, by adding the `cluster`
group into the `extra_packages` group. An error will occur if Ark credentials
are defined in this case, as they are readable by unprivileged users in the
`.repo` files and a local Pulp mirror must be used instead.

If additional repositories are required, these could be added/enabled as necessary in a play added to `environments/$SITE_ENV/hooks/{pre,post}.yml` as appropriate.
Note such a play should NOT exclude the builder group, so that the repositories are also added to built images.
There are various Ansible modules which might be useful for this:

- `ansible.builtin.yum_repository`: Add a repository from a URL providing a 'repodata' directory.
- `ansible.builtin.rpm_key` : Add a GPG key to the RPM database.
- `ansible.builtin.get_url`: Can be used to install a repofile directly from a URL (e.g. <https://turbovnc.org/pmwiki/uploads/Downloads/TurboVNC.repo>)
- `ansible.builtin.dnf`: Can be used to install 'release packages' providing repos, e.g. `epel-release`, `ohpc-release`.

The packages to be installed from that repository could also be defined in that play. Note using the `dnf` module with a list for its `name` parameter is more efficient and allows better dependency resolution than calling the module in a loop.

Adding these repos/packages to the cluster/image would then require running:

    ansible-playbook environments/$SITE_ENV/hooks/{pre,post}.yml

as appropriate.

TODO: improve description about adding these to extra images.

## Reconfiguring Slurm

At a minimum run:

    ansible-playbook ansible/slurm.yml --tags openhpc

**NB:** This will restart all daemons if the `slurm.conf` has any changes, even if technically only a `scontrol reconfigure` is required.

## Running the MPI Test Suite

See [ansible/roles/hpctests/README.md](ansible/roles/hpctests/README.md) for a description of these. They can be run using

    ansible-playbook ansible/adhoc/hpctests.yml

Note that:

- The above role provides variables to select specific partitions, nodes and interfaces which may be required. If not set in inventory, these can be passed as extravars:

        ansible-playbook ansible/adhoc/hpctests.yml -e hpctests_myvar=foo

- The HPL-based test is only reasonably optimised on Intel processors due the libraries and default parallelisation scheme used. For AMD processors it is recommended this
  is skipped using:

          ansible-playbook ansible/adhoc/hpctests.yml --skip-tags hpl-solo.

Review any [site-specific documentation](site/README.md) for more details.

## Running CUDA Tests

This uses the [cuda-samples](https://github.com/NVIDIA/cuda-samples/) utilities "deviceQuery" and "bandwidthTest" to test GPU functionality. It automatically runs on any
host in the `cuda` inventory group:

    ansible-playbook ansible/adhoc/cudatests.yml

**NB:** This test is not launched through Slurm, so confirm nodes are free/out of service or use `--limit` appropriately.

## Ad-hoc Commands and Playbooks

A set of utility playbooks for managing a running appliance are provided in `ansible/adhoc` - run these by activating the environment and using:

        ansible-playbook ansible/adhoc/$PLAYBOOK

Currently they include the following (see each playbook for links to documentation):

- `hpctests.yml`: MPI-based cluster tests for latency, bandwidth and floating point performance.
- `rebuild.yml`: Rebuild nodes with existing or new images (NB: this is intended for development not for reimaging nodes on an in-production cluster).
- `restart-slurm.yml`: Restart all Slurm daemons in the correct order.
- `update-packages.yml`: Update specified packages on cluster nodes (NB: not recommended for routine use).

The `ansible` binary [can be used](https://docs.ansible.com/ansible/latest/command_guide/intro_adhoc.html) to run arbitrary shell commands against inventory groups or hosts, for example:

    ansible [--become] <group/host> -m shell -a "<shell command>"

This can be useful for debugging and development but any modifications made this way will be lost if nodes are rebuilt/reimaged.
