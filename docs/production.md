# Production Deployments

This page will guide you on how to create production-ready deployments. While
you can start right away with this guide, you may find it useful to try with a
demo deployment first, as described in the [main README](../README.md).

## Prerequisites

Before starting ensure that:

  - You have root access on the deploy host.

  - You can create instances from the [latest Slurm appliance
    image](https://github.com/stackhpc/ansible-slurm-appliance/releases),
    which already contains the required packages. This is built and tested in
    StackHPC's CI.

  - You have an SSH keypair defined in OpenStack, with the private key
    available on the deploy host.

  - Created instances have access to internet (note proxies can be setup
    through the appliance if necessary).

  - Created instances have accurate/synchronised time (for VM instances this is
    usually provided by the hypervisor; if not or for bare metal instances it
    may be necessary to configure a time service via the appliance).

  - Three security groups are present: ``default`` allowing intra-cluster
    communication, ``SSH`` allowing external access via SSH and ``HTTPS``
    allowing access for Open OnDemand.

### Setup deploy host

The following operating systems are supported for the deploy host:

  - Rocky Linux 9

  - Rocky Linux 8

These instructions assume the deployment host is running Rocky Linux 8:

```bash
sudo yum install -y git python38
git clone https://github.com/stackhpc/ansible-slurm-appliance
cd ansible-slurm-appliance
git checkout ${latest-release-tag}
./dev/setup-env.sh
```

You will also need to install
[OpenTofu](https://opentofu.org/docs/intro/install/rpm/).

## Version control

A production deployment should be set up under version control, so you should
create a fork of this repo.

To start, you should use the [latest tagged
release](https://github.com/stackhpc/ansible-slurm-appliance/releases). v1.161
has been used as an example here, make sure to channge this. Do not use the
default main branch, as this may have features that are still works in
progress. The steps below show how to create a site-specific branch.

  ```bash
  git clone https://github.com/your-fork/ansible-slurm-appliance
  git checkout v1.161
  git checkout -b site/main
  git push -u origin site/main
  ```

## Environment setup

Get it agreed up front what the cluster names will be. Changing this later
requires instance deletion/recreation.

### Cookiecutter instructions

- Run the following from the repository root to activate the venv:

  ```bash
  . venv/bin/activate
  ```

- Use the `cookiecutter` template to create a new environment to hold your
  configuration:

  ```bash
  cd environments
  cookiecutter skeleton
  ```

  and follow the prompts to complete the environment name and description.

  **NB:** In subsequent sections this new environment is referred to as `$ENV`.

- Go back to the root folder and activate the new environment:

  ```bash
  cd ..
  . environments/$ENV/activate
  ```

  And generate secrets for it:

  ```bash
  ansible-playbook ansible/adhoc/generate-passwords.yml
  ```

### Environments structure

At least three environments will be created:

  - `site`: site-specific base environment

  - `production`: production environment

  - `staging`: staging environment

A `dev` environment should also be created if considered required, or this can
be left until later.

These will all be produced using the cookicutter instructions, but the
`production` and `staging` environments will need their
`environments/$ENV/ansible.cfg` file modifying so that they point to the `site`
environment:

  ```ini
  inventory = ../common/inventory,../site/inventory,inventory
  ```

To avoid divergence of configuration all possible overrides for group/role
vars should be placed in `environments/site/inventory/group_vars/all/*.yml`
unless the value really is environment-specific (e.g. DNS names for
`openondemand_servername`).

Where possible hooks should also be placed in `environments/site/hooks/`
and referenced from the `site` and `production` environments, e.g.:

  ```yaml
  # environments/production/hooks/pre.yml:
  - name: Import parent hook
    import_playbook: "{{ lookup('env', 'APPLIANCES_ENVIRONMENT_ROOT') }}/../site/hooks/pre.yml"
  ```

OpenTofu configurations should be defined in the `site` environment and used
as a module from the other environments. This can be done with the
cookie-cutter generated configurations:

  - Delete the *contents* of the cookie-cutter generated `tofu/` directories
    from the `production` and `staging` environments.

  - Create a `main.tf` in those directories which uses `site/tofu/` as a
    [module](https://opentofu.org/docs/language/modules/), e.g. :

  ```
  ...
  module "cluster" {
      source = "../../site/tofu/"
      cluster_name = "foo"
      ...
  }
  ```

Note that:

  - Environment-specific variables (`cluster_name`) should be hardcoded into
    the cluster module block.

  - Environment-independent variables (e.g. maybe `cluster_net` if the same
    is used for staging and production) should be set as *defaults* in
    `environments/site/tofu/variables.tf`, and then don't need to be passed
    in to the module.

## Define and deploy infrastructure

Create an OpenTofu variables file to define the required infrastructure, e.g.:

  ```
  # environments/$ENV/tofu/terraform.tfvars
  cluster_name = "mycluster"
  cluster_networks = [
    {
      network = "some_network" # *
      subnet = "some_subnet" # *
    }
  ]
  key_pair = "my_key" # *
  control_node_flavor = "some_flavor_name"
  login = {
      # Arbitrary group name for these login nodes
      interactive = {
          nodes: ["login-0"]
          flavor: "login_flavor_name" # *
      }
  }
  cluster_image_id = "rocky_linux_9_image_uuid"
  compute = {
      # Group name used for compute node partition definition
      general = {
          nodes: ["compute-0", "compute-1"]
          flavor: "compute_flavor_name" # *
      }
  }
  ```

Variables marked `*` refer to OpenStack resources which must already exist.

The above is a minimal configuration - for all variables and descriptions see
`environments/$ENV/tofu/variables.tf`.

The cluster image used should match the release which you are deploying with.
Images are published alongside the release tags
[here](https://github.com/stackhpc/ansible-slurm-appliance/releases). 

To deploy this infrastructure, ensure the venv and the environment are
[activated](#cookiecutter-instructions) and run:

  ```bash
  export OS_CLOUD=openstack
  cd environments/$ENV/tofu/
  tofu init
  tofu apply
  ```

and follow the prompts. Note the OS_CLOUD environment variable assumes that
OpenStack credentials are defined using a
[clouds.yaml](https://docs.openstack.org/python-openstackclient/latest/configuration/index.html#clouds-yaml)
file in a default location with the default cloud name of `openstack`.

### Configure appliance

To configure the appliance, ensure the venv and the environment are
[activated](#create-a-new-environment) and run:

  ```bash
  ansible-playbook ansible/site.yml
  ```

Once it completes you can log in to the cluster using:

  ```bash
  ./dev/ansible-ssh login
  ```

## Production further configuration

- Vault-encrypt secrets. Running the `generate-passwords.yml` playbook creates
  a secrets file at `environments/$ENV/inventory/group_vars/all/secrets.yml`.
  To ensure staging environments are a good model for production this should
  generally be moved into the `site` environment. It should be encrypted
  using [Ansible
  vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
  and then committed to the repository.

- Ensure created instances have accurate/synchronised time. For VM instances
  this is usually provided by the hypervisor, but if not (or for bare metal
  instances) it may be necessary to configure or proxy `chronyd` via an
  environment hook.

- By default, the cookiecutter-provided OpenTofu configuration provisions two
  volumes and attaches them to the control node:
    - "$cluster_name-home" for NFS-shared home directories
    - "$cluster_name-state" for monitoring and Slurm data
  The volumes mean this data is persisted when the control node is rebuilt.
  However if the cluster is destroyed with `tofu destroy` then the volumes will
  also be deleted. This is undesirable for production environments and usually
  also for staging environments. Therefore the volumes should be manually
  created, e.g. via the CLI:

      openstack volume create --size 200 mycluster-home # size in GB
      openstack volume create --size 100 mycluster-state

  and OpenTofu configured to use those volumes instead of managing them itself
  by setting:

      home_volume_provisioning = "attach"
      state_volume_provisioning = "attach"

  either for a specific environment within the cluster module block in
  `environments/$ENV/tofu/main.tf`, or as the site default by changing the
  default in `environments/site/tofu/variables.tf`.
  
  For a development environment allowing OpenTofu to manage the volumes using
  the default value of `"manage"` for those varibles is usually appropriate, as
  it allows for multiple clusters to be created with this environment.
  
  If no home volume at all is required because the home directories are provided
  by a parallel filesystem (e.g. manila) set

      home_volume_provisioning = "none"

  In this case the NFS share for home directories is automatically disabled.

  **NB:** To apply "attach" options to existing clusters, first remove the
    volume(s) from the tofu state, e.g.:

      tofu state list # find the volume(s)
      tofu state rm 'module.cluster.openstack_blockstorage_volume_v3.state[0]'
  
  This leaves the volume itself intact, but means OpenTofu "forgets" it. Then
  set the "attach" options and run `tofu apply` again - this should show there
  are no changes planned.

- Enable `etc_hosts` templating:

    ```yaml
    # environments/site/inventory/groups:
    [etc_hosts:children]
    cluster
    ```

- Configure Open OnDemand - see [specific documentation](openondemand.md).

- Remove the `demo_user` user from
  `environments/$ENV/inventory/group_vars/all/basic_users.yml`

- Consider whether having (read-only) access to Grafana without login is OK. If
  not, remove `grafana_auth_anonymous` in
  `environments/$ENV/inventory/group_vars/all/grafana.yml`

- If floating IPs are required for login nodes, these can be set using the
  optional parameter `fip_addresses`. These need to be created in your project
  beforehand.

- A production deployment may have a more complex networking requirements than
  just a simple network. See the [networks docs](networks.md) for details.

- Consider whether mapping of baremetal nodes to ironic nodes is required. See
  [PR 485](https://github.com/stackhpc/ansible-slurm-appliance/pull/485).

- Note [PR 473](https://github.com/stackhpc/ansible-slurm-appliance/pull/473)
  may help identify any site-specific configuration. 

- See the [hpctests docs](../ansible/roles/hpctests/README.md) for advice on
  raising `hpctests_hpl_mem_frac` during tests.

- By default, OpenTofu (and Terraform)
  [limits](https://opentofu.org/docs/cli/commands/apply/#apply-options) the
  number of concurrent operations to 10. This means that for example only 10
  ports or 10 instances can be deployed at once. This should be raised by
  modifying `environments/$ENV/activate` to add a line like:

      export TF_CLI_ARGS_apply="-parallelism=25"

  The value chosen should be the highest value demonstrated during testing.
  Note that any time spent blocked due to this parallelism limit does not count
  against the (un-overridable) internal OpenTofu timeout of 30 minutes

- By default, OpenStack Nova also
  [limits](https://docs.openstack.org/nova/latest/configuration/config.html#DEFAULT.max_concurrent_builds)
  the number of concurrent instance builds to 10. This is per Nova controller,
  so 10x virtual machines per hypervisor. For baremetal nodes it is 10 per
  cloud if the OpenStack version is earlier than Caracel, else this limit can
  be raised using
  [shards](https://specs.openstack.org/openstack/nova-specs/specs/2024.1/implemented/ironic-shards.html).
  In general it should be possible to raise this value to 50-100 if the cloud
  is properly tuned, again, demonstrated through testing.

- Enable alertmanager if Slack is available - see
  [docs/alerting.md](./alerting.md).

- By default, the appliance uses a built-in NFS share backed by an OpenStack
  volume for the cluster home directories. You may find that you want to change
  this. The following alternatives are supported:

  - External NFS
  <!--- External NFS docs TODO --->
  - CephFS via OpenStack Manila
  <!--- filesystems docs TODO --->
  - [Lustre](../roles/lustre/README.md)

- For some features, such as installing [DOCA-OFED](../roles/doca/README.md) or
  [CUDA](../roles/cuda/README.md), you will need to build a custom image. It is
  recommended that you build this on top of the latest existing openhpc image.
  See the [image-build docs](image-build.md) for details.

For further information, including additional configuration guides and
operations instructions, see the [docs](README.md) directory.
