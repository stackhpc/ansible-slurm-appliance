# EXPERIMENTAL: Slurm Controlled Rebuild

> [!NOTE]  
> This functionality is marked as experimental as the required configuration
> or usage may change with further development.

## Overview

This page describes how to update compute nodes to a new image via Slurm. Nodes
are rebuilt between jobs, so the job queue is not affected during a cluster
upgrade.

This functionality involves several roles in the appliance:

- `rebuild`: This deploys and configures a Slurm [RebootProgram](https://slurm.schedmd.com/slurm.conf.html#OPT_RebootProgram)
  which allows Slurm to reboot or rebuild compute nodes via OpenStack. Which
  action is taken depends on whether the current instance image matches the
  desired image or not. The role also contains automation for triggering rebuilds.
- `compute_init`: This provides machinery to apply cluster-specific configuration
  to a newly-reimaged compute node on first boot, allowing it to rejoin the cluster.
- `stackhpc.openhpc`: When Slurm controlled rebuild is enabled, additional
  Slurm configuration is automatically set via this role.

## Initial setup

> [!NOTE]
> Not all appliance functionality is supported by the `compute_init` role yet.
> Review the compatibility list in the role's [README](../../ansible/roles/compute_init/README.md)
> before proceeding.

1. Decide which compute nodes should have rebuild via Slurm enabled. Generally,
   this can be all compute nodes. These are referred to as the "rebuildable"
   nodes below.

2. Configure OpenTofu not to manage image changes on rebuildable nodes.

   For each relevant node group in the OpenTofu `compute` variable, set the
   parameter `ignore_image_changes: true`. E.g.

   ```terraform
   # environments/$ENV/main.tf:
   ...
   compute = {
       general = {
           nodes = ["general-0", "general-1"]
           ignore_image_changes = true
           ...
       }
       gpu = {
           node = ["a100-0", "a100-1"]
           ignore_image_changes = true
           ...
       }
   }
   ...
   ```

   This means that changes to the OpenTofu variables `cluster_image_id` or
   nodegroup overrides `image_id` will no longer cause OpenTofu to rebuild nodes
   on `tofu apply`.

3. Follow the [compute_init role readme](../../ansible/roles/compute_init/README.md)
   to configure that role:
   - Add nodes into the `compute_init` group.
   - Potentially, build an image.
   - Configure the OpenTofu variable `compute_init_enable` to enable specific
     functionality on boot.

4. If a new image was built, update image references in the OpenTofu configuration.
   Normally these should be in:
   - `environments/site/tofu/variables.tf`: `cluster_image_id` for the default
     cluster image.
   - `environments/$ENV/tofu/main.tf`: parameter `image_id` in `compute` nodegroups,
     for nodegroup specific overrides.

5. Follow the [rebuild role readme](../../ansible/roles/rebuild/README.md) to
   configure that role:
   - Add the `control` node into the `rebuild` group.
   - Ensure an application credential to use for rebuilding nodes is available
     on the deploy host (default location `~/.config/openstack/clouds.yaml`) and
     if necessary set `rebuild_clouds_path`

6. Some defaults may need to be overridden based on testing. In particular the
   `rebuild` role variables for batch size and delay may need modifying to avoid
   overloading OpenStack. The Slurm parameter [ResumeTimeout](https://slurm.schedmd.com/slurm.conf.html#OPT_ResumeTimeout)
   may need increasing from the default of 300 seconds, e.g. for high-memory
   baremetal nodes with long boot times. This can be set using:

   ```yaml
   # environments/site/inventory/group_vars/all/openhpc.yml:
   openhpc_config_extra:
     ResumeTimeout: 600 # seconds
   ```

7. Run `tofu apply` as usual to apply the new OpenTofu configuration.

   > [!CAUTION]
   > Due to OpenTofu/Terraform state limitations, this will plan to delete and
   > recreate all compute nodes in node groups where `ignore_image_changes: true`.
   > was not previously set. This is a one-time issue with adding this parameter,
   > i.e. subsequent applies will not require this. This is clearly disruptive
   > to cluster operations and so this should be planned as part of a normal
   > upgrade cycle.
   >
   > Alternatively, it is possible to work around this via `tofu state mv` commands.


   tofu state move \
    'module.cluster.module.compute["extra"].openstack_compute_instance_v2.compute["extra-0"]' \
    'module.cluster.module.compute["extra"].openstack_compute_instance_v2.compute_fixed_image["extra-0"]'

8. Run the `site.yml` playbook as normal to configure the cluster.

The cluster is now ready to perform slurm-controlled upgrades as described in
the next section.

## Upgrade Process

This section explains both the steps required and what happens at each step. Note
this supplements the standard [upgrade docs](../../docs/upgrades.md).

1. Build images and update image reference in the OpenTofu configuration in the
   normal way.
2. Run `tofu apply`: This rebuilds login and control nodes only to the new
   image(s), and also updates the `hosts.yml` inventory file with the new compute
   node image IDs. The login nodes are unavailable to users at this stage and
   Slurm jobs cannot be submitted. Running jobs will continue, but will not be
   able to complete.
3. Run the `site.yml` playbook. This reconfigures the cluster as normal. At this
   point the cluster is functional again; login nodes are available, running jobs
   can complete and new jobs can be submitted. In this point the cluster is running
   in a split state:
   - Login and control nodes are on the new image, with new configuration
   - Compute nodes are on the old image, with new configuration

   This playbook also
   - Writes cluster configuration to an NFS share `/exports/cluster` on the
     control node (via the `compute_init` role).
   - Deploys and configures the RebootProgram (via the `rebuild` role).

4. Submit rebuild requests using:

   ```shell
   ansible-playbook ansible/adhoc/rebuild-via-slurm.yml
   ```

   This will:
   - Find all "rebuildable" nodes which are not currently on the latest image.
   - In batches (to avoid avoid overloading OpenStack APIs):
     - Set nodes to the DRAIN state, so that they can complete existing jobs
       but not run new ones.
     - Issue `scontrol reboot ASAP` commands to request a rebuild once their
       current job has completed.

   The DRAIN state is necessary to avoid the scheduler backfilling jobs onto
   nodes running non-exclusive jobs, which could lead to multi-node jobs running
   on a mix of "old" and "new" nodes.

   See the [rebuild](../../ansible/roles/rebuild/README.md) role variables
   for additional options. In particular note appending `-e rebuild_dryrun=true`
   may be useful to see what commands will be issued.

5. When the rebuilt instance boots, the `compute_init` machinery in the image
   will load configuration from the control node's NFS share and apply it before
   starting `slurmd`. If node health checks are configured (via the
   [nhc](../../ansible/roles/nhc/README.md) role) these then run once. By
   default, the state is then set to UNDRAIN which makes it eligible for jobs
   unless the pre-reboot state prevented this (e.g. it was set DOWN). Again the `rebuild`
   role variables can modify this behaviour.

## Testing

Reimage the cluster (e.g. using ansible/adhoc/rebuild.yml) your cluster to an
older image.
- using v2.24.0 image openhpc-RL9-260818-0723-3f645271
- DONE: tofu deploy using dev key
- DONE: check connectivity
- DONE: ewatch install
- FAILED: site
  - don't have metadata server, on login/control/compute nodes I checked
  - Jack fixed
- DONE: tf destroy
- DONE: TF apply
- FAILED: site - grafana install!
  - ah b/c control is on old image
- DONE reimage control/login via TF
- DONE: site
- FAILED: testing
  - app cred had lapsed
- DONE: fixed, via allowing setting this
- DONE: rebuild compute back to v2.24.0 image
    ansible-playbook --limit compute ansible/adhoc/rebuild.yml -e rebuild_image=openhpc-RL9-260818-0723-3f645271
- DONE: site
- FAILED: retest with updated instructions below
  - nodes didn't come back from DRAIN
- DONE: rebuild compute to v2.25.0 image
- DONE: trying to fix rebuild logic - just set default to resume
- TODO: test again

The below demonstrates testing this using the `.stackhpc` CI environment, using:

- A 2-node default "standard" partition.
- A 2-node "extra" partition (note this does not usually have any nodes by default).

In one terminal launch a watch of job and node states:

```shell
[root@RL9-control rocky]# clear && ~/ewatch/ewatch.py -n 1 -i '\d+:\d+' 'squeue --all && sinfo -R'
```

This uses [ewatch](https://github.com/sjpb/ewatch) to summarise changes in
output.

In a second terminal, launch 2x exclusive jobs into the default ("standard")
partition:

```shell
[demo_user@RL9-login-0 ~]$ sbatch -N2 --exclusive --job-name=JobA --wrap "sleep 60" && sbatch -N2 --exclusive  --job-name=JobB --wrap "sleep 30"
```

On the ansible deploy host, trigger the rebuild:

```shell
.stackhpc/ (venv) [rocky@steveb-dev slurm-app-rl9]$ ansible-playbook ansible/adhoc/rebuild-via-slurm.yml
```
Once this has completed, back in the second terminal, submit another (non-exclusive) job to either partition:

```shell
[demo_user@RL9-login-0 ~]$ sbatch -N2 --job-name=JobC --partition standard,extra --wrap "sleep 10"
```

The output from the first terminal should show:

- Job A runs on submission in the default "standard" partition.
- Job B pends for the default "standard" partition due to lack of resources.
- The "extra" nodes go to "boot" and "standard" go to drain.
- Job C pends for both partitions
- Job A completes
- The "standard" nodes go to "boot".
- Job C runs in the "extra" partition
- Job B runs in the "standard" partition

See example output below. Note for each timestamp the first block comes from `squeue` and the second from `sinfo -R`.

```text
[2026-09-16T15:56:58.042243]
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
                 8  standard     JobB    rocky PD       0:00      2 (Resources)
                 7  standard     JobA    rocky  R       0:01      2 dev-compute-[0-1]
REASON               USER      TIMESTAMP           NODELIST

[2026-09-16T15:57:16.175957]
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
                 8  standard     JobB    rocky PD       0:00      2 (Nodes required for job are DOWN, DRAINED or reserved for jobs in higher priority partitions)
                 7  standard     JobA    rocky  R       0:19      2 dev-compute-[0-1]
REASON               USER      TIMESTAMP           NODELIST
update               root      2026-09-16T15:57:15 dev-compute-[0-1],dev-extra-[0-1]

[2026-09-16T15:57:18.191325]
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
                 8  standard     JobB    rocky PD       0:00      2 (Nodes required for job are DOWN, DRAINED or reserved for jobs in higher priority partitions)
                 7  standard     JobA    rocky  R       0:21      2 dev-compute-[0-1]
REASON               USER      TIMESTAMP           NODELIST
update : reboot issu slurm     2026-09-16T15:57:17 dev-extra-[0-1]
update               root      2026-09-16T15:57:17 dev-compute-[0-1]

[2026-09-16T15:57:24.236222]
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
                 8  standard     JobB    rocky PD       0:00      2 (Nodes required for job are DOWN, DRAINED, REBOOTING or reserved for jobs in higher priority partitions)
                 7  standard     JobA    rocky  R       0:27      2 dev-compute-[0-1]
                 9 standard,     JobC    rocky PD       0:00      2 (Nodes required for job are DOWN, DRAINED, REBOOTING or reserved for jobs in higher priority partitions)
REASON               USER      TIMESTAMP           NODELIST
update : reboot issu slurm     2026-09-16T15:57:17 dev-extra-[0-1]
update               root      2026-09-16T15:57:17 dev-compute-[0-1]

[2026-09-16T15:57:58.503340]
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
                 8  standard     JobB    rocky PD       0:00      2 (Nodes required for job are DOWN, DRAINED, REBOOTING or reserved for jobs in higher priority partitions)
                 9 standard,     JobC    rocky PD       0:00      2 (Nodes required for job are DOWN, DRAINED, REBOOTING or reserved for jobs in higher priority partitions)
REASON               USER      TIMESTAMP           NODELIST
update : reboot issu slurm     2026-09-16T15:57:17 dev-extra-[0-1]
update : reboot issu slurm     2026-09-16T15:57:57 dev-compute-[0-1]

[2026-09-16T16:00:21.648057]
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
                 8  standard     JobB    rocky PD       0:00      2 (Nodes required for job are DOWN, DRAINED, REBOOTING or reserved for jobs in higher priority partitions)
                 9 standard,     JobC    rocky PD       0:00      2 (Nodes required for job are DOWN, DRAINED, REBOOTING or reserved for jobs in higher priority partitions)
REASON               USER      TIMESTAMP           NODELIST
update : reboot issu slurm     2026-09-16T15:57:57 dev-compute-[0-1]

[2026-09-16T16:00:23.662996]
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
                 9     extra     JobC    rocky  R       0:02      2 dev-extra-[0-1]
                 8  standard     JobB    rocky PD       0:00      2 (Nodes required for job are DOWN, DRAINED, REBOOTING or reserved for jobs in higher priority partitions)
REASON               USER      TIMESTAMP           NODELIST
update : reboot issu slurm     2026-09-16T15:57:57 dev-compute-[0-1]

[2026-09-16T16:00:33.745300]
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
                 8  standard     JobB    rocky PD       0:00      2 (Nodes required for job are DOWN, DRAINED, REBOOTING or reserved for jobs in higher priority partitions)
REASON               USER      TIMESTAMP           NODELIST
update : reboot issu slurm     2026-09-16T15:57:57 dev-compute-[0-1]

[2026-09-16T16:01:03.977346]
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
                 8  standard     JobB    rocky  R       0:01      2 dev-compute-[0-1]
REASON               USER      TIMESTAMP           NODELIST
```
