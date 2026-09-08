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

TODO: update

The below demonstrates testing this using the `.stackhpc` CI environment, using:

- A 2-node default "standard" partition.
- A 2-node "extra" partition (note this does not usually have any nodes by default).

In one terminal launch a watch of job state:

```shell
[root@RL9-control rocky]# clear && ~/ewatch/ewatch.py -n 1 -i '\d+:\d+' 'squeue --all --Format=PARTITION,NAME:25,USERNAME:11,STATE:12,NUMNODES:8,NODELIST'
```

This uses [ewatch](https://github.com/sjpb/ewatch) to summarise changes in
output.

In a second terminal, launch 2x normal jobs into the default ("standard")
partition:

```shell
[demo_user@RL9-login-0 ~]$ sbatch -N2 --job-name=JobA --wrap "sleep 60" && sbatch -N2 --job-name=JobB --wrap "sleep 30"
```

In a third terminal, trigger rebuild jobs:

```shell
.stackhpc/ (venv) [rocky@steveb-dev slurm-app-rl9]$ ansible-playbook ansible/adhoc/rebuild-via-slurm.yml
```

Back in the second terminal, submit more user jobs to either partition:

```shell
[demo_user@RL9-login-0 ~]$ sbatch -N2 --job-name=JobC --partition,standard,extra --wrap "sleep 10"
```

The output from the first terminal should show:

- Job A runs on submission in the default "standard" partition.
- Job B pends for the default "standard" partition.
- Rebuild jobs runs on submission in the "extra" partition and pend for the "standard" partition
- Job C pends for both partitions
- Job A completes
- Rebuild jobs run on the "standard" partition, jumping ahead of JobB and JobC
- Rebuild jobs complete in the "extra" partition
- JobC runs in the "extra" partition
- JobC completes
- Rebuild jobs complete in the "standard" partition
- Job B runs in the "standard" partition

Example output:

```text
[2025-03-28T14:26:34.510466]
PARTITION           NAME                     USER       STATE       NODES   NODELIST
standard            JobB                     demo_user  PENDING     2
standard            JobA                     demo_user  RUNNING     2       RL9-compute-[0-1]

[2025-03-28T14:26:38.530213]
PARTITION           NAME                     USER       STATE       NODES   NODELIST
rebuild             rebuild-RL9-compute-1    root       PENDING     1
rebuild             rebuild-RL9-compute-0    root       PENDING     1
rebuild             rebuild-RL9-extra-0      root       RUNNING     1       RL9-extra-0
rebuild             rebuild-RL9-extra-1      root       RUNNING     1       RL9-extra-1
standard            JobB                     demo_user  PENDING     2
standard            JobA                     demo_user  RUNNING     2       RL9-compute-[0-1]
standard,extra      JobC                     demo_user  PENDING     2

[2025-03-28T14:26:54.609651]
PARTITION           NAME                     USER       STATE       NODES   NODELIST
rebuild             rebuild-RL9-compute-0    root       RUNNING     1       RL9-compute-0
rebuild             rebuild-RL9-compute-1    root       RUNNING     1       RL9-compute-1
rebuild             rebuild-RL9-extra-0      root       RUNNING     1       RL9-extra-0
rebuild             rebuild-RL9-extra-1      root       RUNNING     1       RL9-extra-1
standard            JobB                     demo_user  PENDING     2
standard,extra      JobC                     demo_user  PENDING     2

[2025-03-28T14:28:39.091571]
PARTITION           NAME                     USER       STATE       NODES   NODELIST
extra               JobC                     demo_user  RUNNING     2       RL9-extra-[0-1]
rebuild             rebuild-RL9-compute-0    root       RUNNING     1       RL9-compute-0
rebuild             rebuild-RL9-compute-1    root       RUNNING     1       RL9-compute-1
standard            JobB                     demo_user  PENDING     2

[2025-03-28T14:28:49.139349]
PARTITION           NAME                     USER       STATE       NODES   NODELIST
rebuild             rebuild-RL9-compute-0    root       RUNNING     1       RL9-compute-0
rebuild             rebuild-RL9-compute-1    root       RUNNING     1       RL9-compute-1
standard            JobB                     demo_user  PENDING     2

[2025-03-28T14:28:55.168264]
PARTITION           NAME                     USER       STATE       NODES   NODELIST
standard            JobB                     demo_user  RUNNING     2       RL9-compute-[0-1]

[2025-03-28T14:29:05.216346]
PARTITION           NAME                     USER       STATE       NODES   NODELIST
```
