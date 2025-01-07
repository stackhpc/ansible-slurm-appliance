# EXPERIMENTAL: compute-init

Experimental / in-progress functionality to allow compute nodes to rejoin the
cluster after a reboot.

To enable this add compute nodes (or a subset of them into) the `compute_init`
group.

This works as follows:
1. During image build, an ansible-init playbook and supporting files
(e.g. templates, filters, etc) are installed.
2. Cluster instances are created as usual; the above compute-init playbook does
not run.
3. The `site.yml` playbook is run as usual to configure all the instances into
a cluster. In addition, with `compute-init` enabled, a `/exports/cluster` NFS
share is created on the control node containing:
    - an /etc/hosts file for the cluster
    - Hostvars for each compute node
4. On reboot of a compute node, ansible-init runs the compute-init playbook
which:
    a. Checks whether the `enable_compute` metadata flag is set, and exits if
       not.
    b. Tries to mount the above `/exports/cluster` NFS share from the control
       node, and exits if it cannot.
    c. Configures itself using the exported hostvars, depending on the
       `enable_*` flags set in metadata.
    d. Issues an `scontrol` command to resume the node (because Slurm will
       consider it as "unexpectedly rebooted").

The check in 4b. above is what prevents the compute-init script from trying
to configure the node before the services on the control node are available
(which requires running the site.yml playbook).

The following roles/groups are currently fully functional:
- `resolv_conf`: all functionality
- `etc_hosts`: all functionality
- `nfs`: client functionality only
- `manila`: all functionality
- `basic_users`: all functionality, assumes home directory already exists on
  shared storage
- `eessi`: all functionality, assumes `cvmfs_config` is the same on control
  node and all compute nodes.
- `openhpc`: all functionality

All of the above are defined in the skeleton cookiecutter config, and are
toggleable via a terraform compute_init autovar file. In the .stackhpc
environment, the compute init roles are set by default to:
- `enable_compute`: This encompasses the openhpc role functionality while being
  a global toggle for the entire compute-init script.
- `etc_hosts`
- `nfs`
- `basic_users`
- `eessi`

# CI workflow

The compute node rebuild is tested in CI after the tests for rebuilding the
login and control nodes. The process follows

1. Compute nodes are reimaged:

         ansible-playbook -v --limit compute ansible/adhoc/rebuild.yml

2. Ansible-init runs against newly reimaged compute nodes

3. Run sinfo and check nodes have expected slurm state

         ansible-playbook -v ansible/ci/check_slurm.yml

# Development/debugging

To develop/debug changes to the compute script without actually having to build
a new image:

1. Deploy a cluster using tofu and ansible/site.yml as normal. This will
   additionally configure the control node to export compute hostvars over NFS.
   Check the cluster is up.

2. Reimage the compute nodes:

        ansible-playbook --limit compute ansible/adhoc/rebuild.yml

3. Add metadata to a compute node e.g. via Horizon to turn on compute-init
   playbook functionality.

4. Fake an image build to deploy the compute-init playbook:

        ansible-playbook ansible/fatimage.yml --tags compute_init

    NB: This will also re-export the compute hostvars, as the nodes are not
    in the builder group, which conveniently means any changes made to that
    play also get picked up.

5. Fake a reimage of compute to run ansible-init and the compute-init playbook:

    On compute node where metadata was added:

        [root@rl9-compute-0 rocky]# rm -f /var/lib/ansible-init.done && systemctl restart ansible-init
        [root@rl9-compute-0 rocky]# systemctl status ansible-init

    Use `systemctl status ansible-init` to view stdout/stderr from Ansible.

Steps 4/5 can be repeated with changes to the compute script. If required,
reimage the compute node(s) first as in step 2 and/or add additional metadata
as in step 3.


# Design notes
- Duplicating code in roles into the `compute-init` script is unfortunate, but
  does allow developing this functionality without wider changes to the
  appliance.

- In general, we don't want to rely on NFS export. So should e.g. copy files
  from this mount ASAP in the compute-init script. TODO:

- There are a couple of approaches to supporting existing roles using `compute-init`:

  1. Control node copies files resulting from role into cluster exports,
     compute-init copies to local disk. Only works if files are not host-specific
     Examples: etc_hosts, eessi config?
  
  2. Re-implement the role. Works if the role vars are not too complicated,
     (else they all need to be duplicated in compute-init). Could also only
     support certain subsets of role functionality or variables
     Examples: resolv_conf, stackhpc.openhpc

- Some variables are defined using hostvars from other nodes, which aren't
  available v the current approach:

    ```
    [root@rl9-compute-0 rocky]# grep hostvars /mnt/cluster/hostvars/rl9-compute-0/hostvars.yml
        "grafana_address": "{{ hostvars[groups['grafana'].0].api_address }}",
        "grafana_api_address": "{{ hostvars[groups['grafana'].0].internal_address }}",
        "mysql_host": "{{ hostvars[groups['mysql'] | first].api_address }}",
        "nfs_server_default": "{{ hostvars[groups['control'] | first ].internal_address }}",
        "openhpc_slurm_control_host": "{{ hostvars[groups['control'].0].api_address }}",
        "openondemand_address": "{{ hostvars[groups['openondemand'].0].api_address if groups['openondemand'] | count > 0 else '' }}",
        "openondemand_node_proxy_directives": "{{ _opeonondemand_unset_auth if (openondemand_auth == 'basic_pam' and 'openondemand_host_regex' and groups['grafana'] | length > 0 and hostvars[ groups['grafana']  | first]._grafana_auth_is_anonymous) else '' }}",
        "openondemand_servername": "{{ hostvars[ groups['openondemand'] | first].ansible_host }}",
        "prometheus_address": "{{ hostvars[groups['prometheus'].0].api_address }}",
            "{{ hostvars[groups['freeipa_server'].0].ansible_host }}"
    ```

    More generally, there is nothing to stop any group var depending on a
    "{{ hostvars[] }}" interpolation ...

    Only `nfs_server_default` and `openhpc_slurm_control_host` are of concern
    for compute nodes - both of these indirect via `api_address` to
    `inventory_hostname`. This has been worked around by replacing this with
    "{{ groups['control'] | first }}" which does result in the control node
    inventory hostname when templating.

    Note that although `groups` is defined in the templated hostvars, when
    the hostvars are loaded using `include_vars:` is is ignored as it is a
    "magic variable" determined by ansible itself and cannot be set.
