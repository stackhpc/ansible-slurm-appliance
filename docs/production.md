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
  can be left until later.,

  These can all be produced using the cookicutter instructions, but the
  `production` and `staging` environments will need their
  `environments/$ENV/ansible.cfg` file modifying so that they point to the
  `site` environment:

    ```ini
    inventory = ../common/inventory,../site/inventory,inventory
    ```

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
  - Delete the *contents* of the cookie-cutter generated `terraform/` directories
    from the `production` and `staging` environments.
  - Create a `main.tf` in those directories which uses `site/terraform/` as a
    [module](https://opentofu.org/docs/language/modules/), e.g. :

    ```
    ...
    module "cluster" {
        source = "../../site/terraform/"

        cluster_name = "foo"
        ...
    }
    ```

    Note that:
        - Environment-specific variables (`cluster_name`) should be hardcoded
          into the module block.
        - Environment-independent variables (e.g. maybe `cluster_net` if the
          same is used for staging and production) should be set as *defaults*
          in `environments/site/terraform/variables.tf`, and then don't need to
          be passed in to the module.

- Vault-encrypt secrets. Running the `generate-passwords.yml` playbook creates
  a secrets file at `environments/$ENV/inventory/group_vars/all/secrets.yml`.
  To ensure staging environments are a good model for production this should
  generally be moved into the `site` environment. It should be be encrypted
  using [Ansible vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
  and then committed to the repository.

- Ensure created instances have accurate/synchronised time. For VM instances
  this is usually provided by the hypervisor, but if not (or for bare metal
  instances) it may be necessary to configure or proxy `chronyd` via an
  environment hook.

- The cookiecutter provided OpenTofu configurations define resources for home and
  state volumes. The former may not be required if the cluster's `/home` is
  provided from an external filesystem (or Manila). In any case, in at least
  the production environment, and probably also in the staging environment,
  the volumes should be manually created and the resources changed to [data
  resources](https://opentofu.org/docs/language/data-sources/). This ensures that even if the cluster is deleted via tofu, the
  volumes will persist.

  For a development environment, having volumes under tofu control via volume
  resources is usually appropriate as there may be many instantiations
  of this environment.

- Enable `etc_hosts` templating:

    ```yaml
    # environments/site/inventory/groups:
    [etc_hosts:children]
    cluster
    ```

- Configure Open OnDemand - see [specific documentation](openondemand.README.md).

- Remove the `demo_user` user from `environments/$ENV/inventory/group_vars/all/basic_users.yml`

- Consider whether having (read-only) access to Grafana without login is OK. If not, remove `grafana_auth_anonymous` in `environments/$ENV/inventory/group_vars/all/grafana.yml`

- Modify `environments/site/terraform/nodes.tf` to provide fixed IPs for at least
  the control node, and (if not using FIPs) the login node(s):

    ```
    resource "openstack_networking_port_v2" "control" {
        ...
        fixed_ip {
            subnet_id = data.openstack_networking_subnet_v2.cluster_subnet.id
            ip_address = var.control_ip_address
        }
    }
    ```
    
  Note the variable `control_ip_address` is new.

  Using fixed IPs will require either using admin credentials or policy changes.

- If floating IPs are required for login nodes, modify the OpenTofu configurations
  appropriately.

- The main [README.md](../README.md) notes that all nodes require a default
  route. This is to [allow k3s](https://docs.k3s.io/installation/airgap#default-network-route)
  to detect the node's primary IP. Normally nodes get a default route from the
  gateway defined on the subnet, but if networking must differ between hosts this
  can be problematic. For example if the cluster has two networks with only
  some nodes dual-homed, a gateway cannot be set on both subnets as this would
  create routing problems for the dual-homed nodes. In this case set
  `gateway_nmcli_connection = "dummy0"` in the OpenTofu compute group definition(s)
  to create a dummy route using cloud-init as per the linked k3s docs, e.g.:
  
  ```terraform
  # environments/$ENV/tofu/main.tf:
  ...
  compute = {
    general = {
        flavor = "general.v1.small"
        nodes = [
          "general-0",
          "general-1",
        ]
        gateway_nmcli_connection = "dummy0"
  }
  ...
  ```

  Note that the `gateway_nmcli_connection` and `gateway_ip` options can also be
  used to set a real default route in cases where the gateway cannot be defined
  on the subnet for some reason.

- Consider whether mapping of baremetal nodes to ironic nodes is required. See
  [PR 485](https://github.com/stackhpc/ansible-slurm-appliance/pull/485).

- Note [PR 473](https://github.com/stackhpc/ansible-slurm-appliance/pull/473)
  may help identify any site-specific configuration. 
