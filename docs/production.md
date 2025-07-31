# Production Deployments

This page contains some brief notes about differences between the default/demo
configuration (as described in the main [README.md](../README.md)) and
production-ready deployments.

- Get it agreed up front what the cluster names will be. Changing this later
  requires instance deletion/recreation.

- At least three environments should be created:
    - `site`: site-specific base environment
    - `production`: production environment
    - `staging`: staging environment

  A `dev` environment should also be created if considered required, or this
  can be left until later.

  These can all be produced using the cookicutter instructions, but the
  `production` and `staging` environments will need their
  `environments/$ENV/ansible.cfg` file modifying so that they point to the
  `site` environment:

    ```ini
    inventory = ../common/inventory,../site/inventory,inventory
    ```

  In general only the `site` environment will need an `inventory/groups` file -
  this is templated out by cookiecutter and should be modified as required to
  enable features for all environments at the site.

- To avoid divergence of configuration all possible overrides for group/role
vars should be placed in `environments/site/inventory/group_vars/all/*.yml`
unless the value really is environment-specific (e.g. DNS names for
`openondemand_servername`).

- Where possible hooks should also be placed in `environments/site/hooks/`
and referenced from the `site` and `production` environments, e.g.:

    ```yaml
    # environments/production/hooks/pre.yml:
    - name: Import parent hook
      import_playbook: "{{ lookup('env', 'APPLIANCES_ENVIRONMENT_ROOT') }}/../site/hooks/pre.yml"
    ```

- OpenTofu configurations should be defined in the `site` environment and used
  as a module from the other environments. This can be done with the
  cookie-cutter generated configurations:
  - Delete the *contents* of the cookie-cutter generated `tofu/` directories
    from the `production` and `staging` environments.
  - Create a `main.tf` in those directories which uses `site/tofu/` as a
    [module](https://opentofu.org/docs/language/modules/), e.g. :

    ```
    ...
    variable "environment_root" {
      type = string
      description = "Path to environment root, automatically set by activate script"
    }

    module "cluster" {
        source = "../../site/tofu/"
        environment_root = var.environment_root

        cluster_name = "foo"
        ...
    }
    ```

    Note that:
    
    - Environment-specific variables (`cluster_name`) should be hardcoded
      into the cluster module block.
    - Environment-independent variables (e.g. maybe `cluster_net` if the
      same is used for staging and production) should be set as *defaults*
      in `environments/site/tofu/variables.tf`, and then don't need to
      be passed in to the module.

- Vault-encrypt secrets. Running the `generate-passwords.yml` playbook creates
  a secrets file at `environments/$ENV/inventory/group_vars/all/secrets.yml`.
  To ensure staging environments are a good model for production this should
  generally be moved into the `site` environment. It should be encrypted
  using [Ansible vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
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

- Consider whether Prometheus storage configuration is required. By default:
  - A 200GB state volume is provisioned (but see above)
  - The common environment [sets](../environments/common/inventory/group_vars/all/prometheus.yml)
    a maximum retention of 100 GB and 31 days
  These may or may not be appropriate depending on the number of nodes, the
  scrape interval, and other uses of the state volume (primarily the `slurmctld`
  state and the `slurmdbd` database). See [docs/monitoring-and-logging](./monitoring-and-logging.md)
  for more options.

- Configure Open OnDemand - see [specific documentation](openondemand.md) which
  notes specific variables required.

- Remove the `demo_user` user from `environments/$ENV/inventory/group_vars/all/basic_users.yml`

- Consider whether having (read-only) access to Grafana without login is OK. If not, remove `grafana_auth_anonymous` in `environments/$ENV/inventory/group_vars/all/grafana.yml`

- If floating IPs are required for login nodes, create these in OpenStack and add the IPs into
  the OpenTofu `login` definition.

- Consider whether mapping of baremetal nodes to ironic nodes is required. See
  [PR 485](https://github.com/stackhpc/ansible-slurm-appliance/pull/485).

- Note [PR 473](https://github.com/stackhpc/ansible-slurm-appliance/pull/473)
  may help identify any site-specific configuration. 

- See the [hpctests docs](../ansible/roles/hpctests/README.md) for advice on
  raising `hpctests_hpl_mem_frac` during tests.

- By default, OpenTofu (and Terraform) [limits](https://opentofu.org/docs/cli/commands/apply/#apply-options)
  the number of concurrent operations to 10. This means that for example only
  10 ports or 10 instances can be deployed at once. This should be raised by
  modifying `environments/$ENV/activate` to add a line like:

      export TF_CLI_ARGS_apply="-parallelism=25"

  The value chosen should be the highest value demonstrated during testing.
  Note that any time spent blocked due to this parallelism limit does not count
  against the (un-overridable) internal OpenTofu timeout of 30 minutes

- By default, OpenStack Nova also [limits](https://docs.openstack.org/nova/latest/configuration/config.html#DEFAULT.max_concurrent_builds)
  the number of concurrent instance builds to 10. This is per Nova controller,
  so 10x virtual machines per hypervisor. For baremetal nodes it is 10 per cloud
  if the OpenStack version is earlier than Caracel, else this limit can be
  raised using [shards](https://specs.openstack.org/openstack/nova-specs/specs/2024.1/implemented/ironic-shards.html).
  In general it should be possible to raise this value to 50-100 if the cloud
  is properly tuned, again, demonstrated through testing.

- Enable alertmanager if Slack is available - see [docs/alerting.md](./alerting.md).

- Enable node health checks - see [ansible/roles/nhc/README.md](../ansible/roles/nhc/README.md).
