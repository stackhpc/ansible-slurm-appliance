# EXPERIMENTAL: Slurm Controlled Rebuild

This page describes how to configure the appliance to enable reimaging of
Slurm nodes via submission of Slurm jobs, and how to use that functionality.
This provides a way to upgrade nodes with less impact than the normal approach.

> [!NOTE]  
> This functionality is marked as experimental as the required configuration
> or usage may change with further development.

In summary, the way this functionality works is as follows:

1. The image references(s) are manually updated in the OpenTofu configuration
   in the normal way.
2. `ansible-playbook lock_unlock_instances.yml --limit control,login -e "appliances_server_action=unlock"`
   is run to unlock the control and login nodes for reimaging.
3. `tofu apply` is run which rebuilds the login and control nodes to the new
   image(s). The new image reference for compute nodes is ignored, but is
   written into the hosts inventory file (and is therefore available as an
   Ansible hostvar).
4. The `site.yml` playbook is run which locks the instances again and reconfigures
   the cluster as normal. At this point the cluster is functional, but using a new
   image for the login and control nodes and the old image for the compute nodes.
   This playbook also:
   - Writes cluster configuration to the control node, using the
     [compute_init](../../ansible/roles/compute_init/README.md) role.
   - Configures an application credential and helper programs on the control
     node, using the [rebuild](../../ansible/roles/rebuild/README.md) role.
5. An admin submits Slurm jobs, one for each node, to a special "rebuild"
   partition using an Ansible playbook. Because this partition has higher
   priority than the partitions normal users can use, these rebuild jobs become
   the next job in the queue for every node (although any jobs currently
   running will complete as normal).
6. Because these rebuild jobs have the `--reboot` flag set, before launching them
   the Slurm control node runs a [RebootProgram](https://slurm.schedmd.com/slurm.conf.html#OPT_RebootProgram)
   which compares the current image for the node to the one in the cluster
   configuration, and if it does not match, uses OpenStack to rebuild the
   node to the desired (updated) image.
   TODO: Describe the logic if they DO match
7. After a rebuild, the compute node runs various Ansible tasks during boot,
   controlled by the [compute_init](../../ansible/roles/compute_init/README.md)
   role, to fully configure the node again. It retrieves the required cluster
   configuration information from the control node via an NFS mount.
8. Once the `slurmd` daemon starts on a compute node, the slurm controller
   registers the node as having finished rebooting. It then launches the actual
   job, which does not do anything.

## Prerequsites

To enable a compute node to rejoin the cluster after a rebuild, functionality
must be built into the image. Before progressing you should check that all the
functionality required for your cluster is currently supported by the
`compute_init` role. Review that role's [Readme](../../ansible/roles/compute_init/README.md)
against `environments/*/inventory/groups` files (and any similar files which
define groups). Note that some functionality does not require support, e.g.
because it does not run on compute nodes.

## Configuration

The configuration of this is complex and involves:

- OpenTofu variables to stop tracking image changes on compute nodes
- Definition of partition(s) to use for launching rebuild jobs
- Configuration of the [rebuild](../../ansible/roles/rebuild/README.md) role
  to enable the Slurm controller to rebuild compute nodes via OpenStack.
- Configuration of the [compute_init](../../ansible/roles/compute_init/README.md)
  role so that compute nodes rejoin the cluster after rebuilding - this is likely
  to require a custom image build.

1. Decide on which nodes rebuilding via Slurm should be enabled. These are
   referred to as the "rebuildable" nodes below. Generally, this can be all
   compute nodes.

2. Configure OpenTofu not to manage image changes on rebuildable nodes: For each
   relevant node group in the OpenTofu `compute` variable, set the
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

3. Follow the [compute_init](../../ansible/roles/compute_init/README.md) readme
   to add OpenTofu and Ansible configuration for that role. The "rebootable"
   nodes should all be in the `compute_init` group with the `compute_init_enable`
   OpenTofu parameter set.

4. If the [compute_init](../../ansible/roles/compute_init/README.md) readme
   showed that a custom image is required for any entry in the
   `compute_init_enable` parameter, follow the usual process to build new
   images as required.

5. Update image references in the OpenTofu configuration. Normally these should
   be in:

   - `environments/site/tofu/variables.tf`: `cluster_image_id` for the default
     cluster image.
   - `environments/$ENV/tofu/main.tf`: parameter `image_id` in node groups
     defined in the `compute` or `login` variables, to override the default
     image for specific node groups.

6. Ensure `openhpc_partitions` contains a partition covering the nodes to run
   rebuild jobs. The default definition in `environments/common/inventory/group_vars/all/openhpc.yml`
   will automatically include this via `openhpc_rebuild_partition` also in that
   file. If modifying this, note the important parameters are:

   - `name`: Partition name matching `rebuild` role variable `rebuild_partitions`,
     default `rebuild`.
   - `groups`: A list of nodegroup names, matching `openhpc_nodegroup` and
     keys in the OpenTofu `compute` variable (see example in step 2 above).
     Normally every compute node group should be listed here, unless
     Slurm-controlled rebuild is not required for certain node groups.
   - `default`: Must be set to `NO` so that it is not the default partition.
   - `maxtime`: Maximum time to allow for rebuild jobs, in
     [slurm.conf format](https://slurm.schedmd.com/slurm.conf.html#OPT_MaxTime).
     The example here is 30 minutes, but see discussion below.
   - `partition_params`: A mapping of additional parameters, which must be set
     as follows:
     - `PriorityJobFactor`: Ensures jobs in this partition (i.e. rebuild jobs)
       are always scheduled before jobs in "normal" partitions on the same
       nodes. This value is the highest which can be set. See
       [slurm.conf docs](https://slurm.schedmd.com/slurm.conf.html#OPT_PriorityJobFactor).
       Note this is used instead of `PriorityTier` as the latter (with the
       default appliance configuration) allows rebuild jobs to preempt and
       suspend running user jobs, which is probably undesirable.
     - `Hidden`: Don't show this partition in e.g. `sinfo` for unpriviledged
       users.
     - `RootOnly`: Only allow the root user to submit jobs to this partition.
     - `DisableRootJobs`: Don't disable the root user, in case this parameter
       is set globally via `openhpc_config_extra`.
     - `PreemptMode`: Don't allow reboot jobs to be preempted/suspended.
     - `OverSubscribe`: Ensure that jobs run in this partition require the
       entire node. This means they do not run on nodes as the same time as
       user jobs running in partitions allowing non-exclusive use.

   The value for `maxtime` needs to be sufficent not just for a single node
   to be rebuilt, but also to allow for any batching in either OpenTofu or
   in Nova - see remarks in the [production docs](../production.md).

   If it is desirable to roll out changes more gradually, it is possible to
   create multiple "rebuild" partitions, but it is necessary that:

   - The rebuild partitions should not themselves overlap, else nodes may be
     rebuilt more than once.
   - Each rebuild partition should entirely cover one or more "normal"
     partitions, to avoid the possibility of user jobs being scheduled to a
     mix of nodes using old and new images.

7. Configure the [rebuild](../../ansible/roles/rebuild/README.md) role:

   - Add the `control` node into the `rebuild` group.
   - Ensure an application credential to use for rebuilding nodes is available
     on the deploy host (default location `~/.config/openstack/clouds.yaml`).
   - If required, override `rebuild_clouds_path` or other variables in the site
     environment.

8. Run `tofu apply` as usual to apply the new OpenTofu configuration.

   > [!NOTE]
   > If the cluster image references were updated at step 5, this will be
   > a disruptive operation and should be planned as part of a normal upgrade
   > cycle.
   >
   > [!CAUTION]
   > Due to OpenTofu/Terraform state limitations, this will plan to delete and
   > recreate all compute nodes in node groups where `ignore_image_changes: true`.
   > was not previously set. This is a one-time issue with adding this
   > parameter, i.e. subsequent applys will not require this.

TODO: clarify whether, if the image is bumped at this point, the compute nodes
actually get recreated on the new or the old image??

8. Run the `site.yml` playbook as normal to configure the cluster.

The cluster is now ready to perform slurm-controlled upgrades as described in
the next section.

## Operations with Slurm-controlled Rebuilds

This section describes how to trigger and control Slurm-controlled rebuilds.
However in general these are likely to be done as part of a general cluster
upgrade. As described in the introduction to this page that will involve
rebuilding the login and control nodes to the new image then re-running the
`site.yml` playbook to reconfigure the cluster. That process is disruptive in
that users have no access via SSH or Open Ondemand while it is occuring.
However there is no need to drain compute nodes and create reservations etc.

Triggering rebuild jobs is done using the following playbook:

```shell
ansible-playbook ansible/adhoc/rebuild-via-slurm.yml
```

This will create jobs to reimage every slurm-rebuildable node to the image
currently defined in the OpenTofu configuration.

Note that some of the [rebuild role variables](../../ansible/roles/rebuild/README.md)
may also be useful as extravars, especially for testing or debugging. For
example the following comand will run in a non-default partition and does not
actually reboot/rebuild nodes, which may be useful for testing interactions with
other priority or QOS settings:

```shell
ansible-playbook ansible/adhoc/rebuild-via-slurm.yml -e 'rebuild_job_partitions=test rebuild_job_reboot=false'
```

## Testing

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
[demo_user@RL9-login-0 ~]$ sbatch -N2 --job-name=JobA --wrap "sleep 20" && sbatch -N2 --job-name=JobB --wrap "sleep 10"
```

In a third terminal, trigger rebuild jobs:

```shell
.stackhpc/ (venv) [rocky@steveb-dev slurm-app-rl9]$ ansible-playbook ansible/adhoc/rebuild-via-slurm.yml -e 'rebuild_job_reboot=false rebuild_job_command="sleep 30"' -
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
- Rebuild jobs complete in the "extra" paritition
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
