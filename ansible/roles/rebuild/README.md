# rebuild

This provides two sets of functionality:

- `tasks/main.yml`: Install and configure the the `reboot.py` tool from
  [stackhpc.slurm-openstack-tools](https://github.com/stackhpc/slurm-openstack-tools.git)
  as a Slurm [RebootProgram](https://slurm.schedmd.com/slurm.conf.html#OPT_RebootProgram) on the control node.
- `tasks/rebuild.yml`: Submit batched `scontrol reboot` commands to trigger
  the above.

See [docs/experimental/slurm-controlled-rebuild.md](../../../docs/experimental/slurm-controlled-rebuild.md)
for interaction with other roles and how to enable this.

## Requirements

An OpenStack clouds.yaml file containing credentials for a cloud under the
"openstack" key.

## Role Variables for tasks/main.yml

- `rebuild_clouds_path`: Optional. Path to `clouds.yaml` file on the deploy
  host, default `~/.config/openstack/clouds.yaml`.

## Role Variables for tasks/rebuild.yml

- `rebuild_nodes`: Optional list. Inventory hostnames/nodenames to consider
  submitting for rebuild. The default is all nodes in the `compute_init` group.
  **IMPORTANT:** to avoid jobs landing on a mix of updated and non-updated nodes,
  this group must contain _all_ nodes in partitions for which it includes nodes.
- `rebuild_dryrun`: Optional bool. If `true` it will echo commands instead of
  issuing them. Default `false`.
- `rebuild_reason`: Optional string. A message to show in e.g. `sinfo` describing
  the reason for the rebuild. Default `update`.
- `rebuild_nextstate`: Optional string, one of `RESUME`, `DOWN` or `UNDRAIN` (default).
  The state rebuilt nodes should go to after they are back up.
- `rebuild_batch_size`: Optional integer. The number of nodes to rebuild per batch.
  Default 50.
- `rebuild_batch_delay`: Optional integer. The number of seconds to wait between
  batched rebuild commands. Note this this does not wait for rebuilds to complete
  before moving to the next batch.
