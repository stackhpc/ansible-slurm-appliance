# EXPERIMENTAL: compute_init

Experimental functionality to allow compute nodes to rejoin the cluster after
a reboot without running the `ansible/site.yml` playbook.

To enable this:
1. Add the `compute` group (or a subset) into the `compute_init` group. This is
   the default when using cookiecutter to create an environment, via the
   "everything" template.
2. Build an image which includes the `compute_init` group. This is the case
   for StackHPC-built release images.
3. Enable the required functionalities during boot, by setting the
   `compute_init_enable` property for a compute group in the
   OpenTofu `compute` variable to a list which includes "compute", plus the
   other roles/functionalities required, e.g.:

   ```terraform
   ...
   compute = {
      general = {
         nodes = ["general-0", "general-1"]
         compute_init_enable = ["compute", ... ] # see below
      }
   }
   ...
   ```

## Supported appliance functionalities

In the table below, if a role is marked as supported then its functionality
can be enabled during boot by adding the role name to the `compute_init_enable`
property described above. If a role is marked as requiring a custom image then
it also requires an image build with the role name added to the
[Packer inventory_groups variable](../../../docs/image-build.md).

| Playbook                 | Role (or functionality) | Support                         | Custom image reqd.? |
| -------------------------|-------------------------|---------------------------------|---------------------|
| hooks/pre.yml            | ?                       | None at present                 | n/a                 |
| validate.yml             | n/a                     | Not relevant during boot        | n/a                 |
| bootstrap.yml            | (wait for ansible-init) | Not relevant during boot        | n/a                 |
| bootstrap.yml            | resolv_conf             | Fully supported                 | No                  |
| bootstrap.yml            | etc_hosts               | Fully supported                 | No                  |
| bootstrap.yml            | proxy                   | None at present                 | No                  |
| bootstrap.yml            | (/etc permissions)      | None required - use image build | No                  |
| bootstrap.yml            | (ssh /home fix)         | None required - use image build | No                  |
| bootstrap.yml            | (system users)          | None required - use image build | No                  |
| bootstrap.yml            | systemd                 | None required - use image build | No                  |
| bootstrap.yml            | selinux                 | None required - use image build | Maybe [7]           |
| bootstrap.yml            | sshd                    | None at present                 | No                  |
| bootstrap.yml            | dnf_repos               | None at present [8]             | -                   |
| bootstrap.yml            | squid                   | Not relevant for compute nodes  | n/a                 |
| bootstrap.yml            | tuned                   | None                            | -                   |         
| bootstrap.yml            | freeipa_server          | Not relevant for compute nodes  | n/a                 |
| bootstrap.yml            | cockpit                 | None required - use image build | No                  |
| bootstrap.yml            | firewalld               | Not relevant for compute nodes  | n/a                 |
| bootstrap.yml            | fail2ban                | Not relevant for compute nodes  | n/a                 |
| bootstrap.yml            | podman                  | Not relevant for compute nodes  | n/a                 |
| bootstrap.yml            | update                  | Not relevant during boot        | n/a                 |
| bootstrap.yml            | reboot                  | Not relevant for compute nodes  | n/a                 |
| bootstrap.yml            | ofed                    | Not relevant during boot        | Yes                 |
| bootstrap.yml            | ansible_init (install)  | Not relevant during boot        | n/a                 |
| bootstrap.yml            | k3s (install)           | Not relevant during boot        | n/a                 |
| hooks/post-bootstrap.yml | ?                       | None at present                 | n/a                 |
| iam.yml                  | freeipa_client          | None at present [1]             | Yes                 |
| iam.yml                  | freeipa_server          | Not relevant for compute nodes  | n/a                 |
| iam.yml                  | sssd                    | None at present                 | No                  |
| filesystems.yml          | block_devices           | None required - role deprecated | n/a                 |
| filesystems.yml          | nfs                     | All client functionality        | No                  |
| filesystems.yml          | manila                  | All functionality               | No [10]             |
| filesystems.yml          | lustre                  | None at present                 | Yes                 |
| extras.yml               | basic_users             | All functionality [2]           | No                  |
| extras.yml               | eessi                   | All functionality [3]           | No                  |
| extras.yml               | cuda                    | None required - use image build | Yes [4]             |
| extras.yml               | persist_hostkeys        | Not relevant for compute nodes  | n/a                 |
| extras.yml               | compute_init (export)   | Not relevant for compute nodes  | n/a                 |
| extras.yml               | k9s (install)           | Not relevant during boot        | n/a                 |
| extras.yml               | extra_packages          | None at present [9]             | -                   |
| slurm.yml                | mysql                   | Not relevant for compute nodes  | n/a                 |
| slurm.yml                | rebuild                 | Not relevant for compute nodes  | n/a                 |
| slurm.yml                | openhpc [5]             | All slurmd functionality        | No                  |
| slurm.yml                | (set memory limits)     | None at present                 | -                   |
| slurm.yml                | (block ssh)             | None at present                 | -                   |
| portal.yml               | (openondemand server)   | Not relevant for compute nodes  | n/a                 |
| portal.yml               | (openondemand vnc desktop)  | None required - use image build | No              |
| portal.yml               | (openondemand jupyter server) | None required - use image build | No            |
| monitoring.yml           | (all monitoring)        | None at present [6]             | -                   |
| disable-repos.yml        | dnf_repos               | None at present [8]             | -                   |
| hooks/post.yml           | ?                       | None at present                 | -                   |


Notes:
1. FreeIPA client functionality would be better provided using a client fork
   which uses pkinit keys rather than OTP to reenrol nodes.
2. Assumes home directory already exists on shared storage.
3. Assumes `cvmfs_config` is the same on control node and all compute nodes
4. If `cuda` role was run during build, the nvidia-persistenced is enabled
  and will start during boot.
5. `openhpc` does not need to be added to `compute_init_enable`, this is
   automatically enabled by adding `compute`.
6. Only node-exporter tasks are relevant, and will be done via k3s in a future release.
7. `selinux` is set to disabled in StackHPC images.
8. Requirement TBD
9. Would require dnf_repos
10. Assuming default cephfs version


## Approach
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

## Development/debugging

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


## Design notes
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
