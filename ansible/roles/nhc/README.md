# Node Health Checks (nhc)

Deploys and configures the LBNL [Node Health Check](https://github.com/mej/nhc)
(NHC) which will put nodes in `DOWN` state if they fail periodic checks on
various aspects.

Due to the integration with Slurm this is tightly linked to the configuration
for the [stackhpc.openhpc](../stackhpc.openhpc/README.md) role.

## Enabling

By [default](../../../environments/common/inventory/group_vars/all/openhpc.yml)
the required `nhc-ohpc` packages are installed in all images.

To enable node health checks, ensure the `nhc` group contains the `compute` group:

```yaml
# environments/site/inventory/groups:
[nhc:children]
# Hosts to configure for node health checks
compute
```

When the `ansible/site.yml` playbook is run this will automatically:

1. Add NHC-related configuration to the `slurm.conf` Slurm configuration file.
   The default configuration is defined in `openhpc_config_nhc`
   (see [environments/common/inventory/group_vars/all/openhpc.yml](../../../environments/common/inventory/group_vars/all/openhpc.yml)).
   It will run healthchecks on all `IDLE` nodes which are not `DRAINED` or
   `NOT_RESPONDING` every 300 seconds. See [slurm.conf parameters](https://slurm.schedmd.com/slurm.conf.html)
   `HealthCheckInterval`, `HealthCheckNodeState`, `HealthCheckProgram`. These
   may be overriden if required by redefining `openhpc_config_nhc` in e.g.
   `environments/site/inventory/group_vars/nhc/yml`.

2. Template out node health check rules using Ansible facts for each compute
   node. Currently these check:
   - Filesystem mounts
   - Ethernet interfaces
   - InfiniBand interfaces

   See `/etc/nhc/nhc.conf` on a compute node for the full configuration.

If a node healthcheck run fails, Slurm will mark the node `DOWN`. With the
default [alerting configuration](../../../docs/alerting.md) this will trigger
an alert.

## Role Variables

- `nhc_config_template`: Template to use. Default is the in-role template
  providing rules described above.
- `nhc_config_extra`: Possibly multiline string defining [additional rules](https://github.com/mej/nhc/blob/master/README.md) to
  add. Jinja templating may be used. Default is empty string.

## Structure

This role contains 3x task files, which run at different times:

- `main.yml`: Runs from `site.yml` -> `slurm.yml`. Templates health check
  configuration to nodes.
- `export.yml`: Runs from `site.yml` -> `final.yml` via role `compute_init`
  tasks `export.yml`. Templates health check configuration to the cluster NFS
  share for compute-init.
- `boot.yml`: Runs on boot via `compute_init/files/compute-init.yml`. Copies
  the node's generated health check configuration from the cluster share to
  local disk.

Note that the `stackhpc.openhpc` role:

- Installs the required package
- Configures slurm.conf parameterss
