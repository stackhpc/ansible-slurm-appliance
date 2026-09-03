# rebuild

This role:
- Installs and configures the `reboot.py` tool from https://github.com/stackhpc/slurm-openstack-tools
  on the control node. This allows compute nodes to be rebuilt or rebooted via
  Slurm's `scontrol rebuild ASAP ...` command.
- Provides a `rebuild.yml` task file to automate issuing of those commands.

Note that whether a node is rebuilt to a new image or simply rebooted depends
on whether a node's current image matches the desired one or not. See the
[Slurm controlled rebuild](docs/experimental/slurm-controlled-rebuild.md) docs
for more details.

To avoid overloading OpenStack APIs, `scontrol reboot ...` commands are issued
in batches.

## Requirements

An OpenStack clouds.yaml file containing credentials for a cloud under the
"openstack" key.

## Role Variables for main.yml task file
This is relevant when running the `ansible/site.yml` or `ansible/slurm.yml` playbooks:

- `rebuild_clouds_path`: Optional. Path to `clouds.yaml` file on the deploy
  host, default `~/.config/openstack/clouds.yaml`.

## Role Variables for rebuild.yml task file
These are relevant when running the `ansible/adhoc/rebuild-via-slurm.yml` playbook.

- `rebuild_reason`: Optional, default `update`. The reason for the rebuild/reboot,
  shown in `sinfo` output.
- `rebuild_nextstate`: Optional, default `UNDRAIN`. The next state for the node
  once the slurmd has re-registered after the rebuild/reboot. Generally the default
  is appropriate to allow any pre-existing state (e.g. `DOWN`) to persist.
- `rebuild_batch_size`: Optional, default `50`. The number of nodes to rebuild
  at once.
- `rebuild_batch_delay`: Optional, default `60`. The number of seconds to wait
  between issuing `scontrol reboot` commands for each batch. Note it does not
  wait for the rebuilt to complete before moving to the next batch.
- `rebuild_batch_start`: Optional, default `0`. The index of the first batch to
  start from. This allows skipping successful batches if trying to recover failed
  batches.

For further information on reason and nextstate behaviour see the [scontrol reboot
documentation](https://slurm.schedmd.com/scontrol.html#lbAF). Note that to avoid
multi-node jobs landing on a mix of pre- and post-rebuild nodes it is not
possible to specify nodes via a NodeList or NodeSet here.
