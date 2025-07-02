# Isolated Clusters

Full functionality of the appliance requires that there is outbound internet
access from all nodes, possibly via a [proxy](../../ansible/roles/proxy/).

However many features (as defined by Ansible inventory groups/roles) will work
if the cluster network(s) provide no outbound access. Currently this includes
all "default" features, i.e. roles/groups which are enabled either in the
`common` environment or in the `environments/$ENV/inventory/groups` file
created by cookiecutter for a new environment.

The full list of features and whether they are functional on such an "isolated" network is shown in the table below. Note that:

1. The `hpl` test from the `ansible/adhoc/hpctests.yml` playbook is not
   functional and must be skipped using:

    ```shell
    ansible-playbook ansible/adhoc/hpctests.yml --skip-tags hpl-solo
    ```

2. Using [EESSI](https://www.eessi.io/docs/) necessarily requires outbound
   network access for the CernVM File System. However this can be provided
   via an authenticated proxy. While the proxy configuration on the cluster node
   is readable by all users, this proxy can provide access only to EESSI's
   CVMFS Stratum 1 servers.

## Support by feature for isolated networks

See above for definition of "Default" features. In the "Isolated?" column:
- "Y": Feature works without outbound internet access.
- "N": Known not to work.
- "?": Not investigated at present.

| Inventory group/role  | Default? | Isolated? |
| ----------------------| -------- | --------- |
| alertmanager          | Y | Y | 
| ansible_init          | Y | Y | 
| basic_users           | Y | Y | 
| block_devices         | Y | No (depreciated) | 
| cacerts               | - | Y | 
| chrony                | - | Y | 
| compute_init          | - | Y | 
| cuda                  | - | ? | 
| eessi                 | Y | Y - see above | 
| etc_hosts             | Y | Y | 
| extra_packages        | - | No | 
| fail2ban              | Y | Y | 
| filebeat              | Y | Y | 
| firewalld             | Y | Y | 
| gateway               | n/a | n/a - build only | 
| grafana               | Y | Y | 
| hpctests              | Y | Y  - except hpl-solo, see above | 
| k3s_agent             | - | ? | 
| k3s_server            | - | ? | 
| k9s                   | - | ? | 
| lustre                | - | ? | 
| manila                | Y | Y | 
| mysql                 | Y | Y | 
| nfs                   | Y | Y | 
| nhc                   | Y | Y | 
| node_exporter         | Y | Y | 
| openhpc               | Y | Y | 
| openondemand          | Y | Y | 
| openondemand_desktop  | Y | Y | 
| openondemand_jupyter  | Y | Y | 
| opensearch            | Y | Y | 
| podman                | Y | Y | 
| persist_hostkeys      | Y | Y | 
| prometheus            | Y | Y | 
| proxy                 | - | Y | 
| resolv_conf           | - | ? | 
| slurm_exporter        | Y | Y | 
| slurm_stats           | Y | Y | 
| squid                 | - | ? | 
| sshd                  | - | ? | 
| sssd                  | - | ? | 
| systemd               | Y | Y | 
| tuned                 | - | Y | 
| update                | - | No |

## Network considerations

Even when outbound internet access is not required, nodes do require some outbound access, as well as connectivity inbound from the deploy host and
inbound connectivity for users. This section documents the minimal connectivity required, in the form of the minimally-permissive security group rules. Often default security groups are less restrictive than these.

Assuming nodes and the deploy host have a security group `isolated` applied then the following rules are required:

    # allow outbound DNS
    ALLOW IPv4 53/tcp to 0.0.0.0/0
    ALLOW IPv4 53/udp to 0.0.0.0/0
    
    # allow everything within the cluster:
    ALLOW IPv4 from isolated
    ALLOW IPv4 to isolated
    
    # allow hosts to reach metadata server (e.g. for cloud-init keys):
    ALLOW IPv4 80/tcp to 169.254.169.254/32

    # optionally: allow hosts to reach squid proxy for EESSI:
    ALLOW IPv4 3128/tcp to <squid cidr>

Note that name resolution happens on the hosts, not on the proxy, hence DNS is required for nodes even with a proxy.

For nodes running OpenOndemand, inbound ssh and https are also required
(e.g. in a security group called `isolated-ssh-https`):

    ALLOW IPv4 443/tcp from 0.0.0.0/0
    ALLOW IPv4 22/tcp from 0.0.0.0/0

If non-default security groups are required, then the OpenTofu variables `login_security_groups` and `nonlogin_security_groups` can be used to set these, e.g.:

```terraform
# environments/site/tofu/cluster.auto.tfvars:
login_security_groups = [
    "isolated",  # allow all in-cluster services
    "isolated-ssh-https",      # access via ssh and ondemand
]
nonlogin_security_groups = [
    "isolated"
]
```
