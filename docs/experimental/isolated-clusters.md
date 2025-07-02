# Isolated Clusters

By default, the appliance assumes and requires that there is outbound internet
access, possibly via a [proxy](../../ansible/roles/proxy/) . However it is
possible to create clusters in more restrictive environments, with some
limitations on functionality.

## No outbound internet

A cluster can be deployed using the upstream image (or one derived from it) without any outbound internet at all.

At present, this supports all roles/groups enabled:
- Directly in the `common` environment
- In the `environments/$ENV/inventory/groups` file created by cookiecutter for
  a new environment (from the "everything template").

plus some additional roles/groups not enabled by default listed below.

Note that the `hpl` test from the `ansible/adhoc/hpctests.yml` playbook is not
functional and must be skipped using:

```shell
ansible-playbook ansible/adhoc/hpctests.yml --skip-tags hpl-solo
```

The full list of supported roles/groups is below, with those marked "*"
enabled by default in the common environment or "everything template":
- alertmanager *
- ansible_init *
- basic_users *
- cacerts 
- chrony
- eessi *
- etc_hosts *
- filebeat *
- grafana *
- mysql *
- nfs *
- node_exporter *
- openhpc *
- opensearch *
- podman *
- prometheus *
- proxy
- rebuild
- selinux **
- slurm_exporter *
- slurm_stats *
- systemd **
- tuned
- fail2ban *
- firewalld *
- hpctests *
- openondemand *
- persist_hostkeys *
- compute_init
- nhc *
- openondemand_desktop *

Note that for this to work, all dnf repositories are disabled at the end of
image builds, so that `ansible.builtin.dnf` tasks work when running against
packages already installed in the image.

## Outbound internet via proxy not available to cluster users
If additional functionality is required it is possible configure Ansible to use
an authenticated http/https proxy (e.g. [squid](https://www.squid-cache.org/)).
The proxy credentials are not written to the cluster nodes so the proxy cannot
be used by cluster users.

To do this the proxy variables required in the remote environment must be
defined for the Ansible variable `appliances_remote_environment_vars`. Note
some default proxy variables are provided in `environments/common/inventory/group_vars/all/proxy.yml` so generally it will be sufficient set the proxy user, password and address and to add these to the remote environment:

```yaml
# environments/site/inventory/group_vars/all/proxy.yml:
proxy_basic_user: my_squid_user
proxy_basic_password: "{{ vault_proxy_basic_password }}"
proxy_http_address: squid.mysite.org

# environments/site/inventory/group_vars/all/vault_proxy.yml:
# NB: ansible vault-encrypt this file
vault_proxy_basic_password: super-secret-password

# environments/site/inventory/group_vars/all/default.yml:
appliances_remote_environment_vars:
    http_proxy: "{{ proxy_http_proxy }}"
    https_proxy: "{{ proxy_http_proxy }}"
```

TODO: Do we need to set `no_proxy`??

This uses Ansible's [remote environment support](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_environment.html). Currrently this is suported for the following roles/groups:
- eessi: TODO: is this right though??
- manila


Although EESSI will install with the above configuration, as there is no
outbound internet access except for Ansible tasks, making it functional will
require [configuring a proxy for CVMFS](https://multixscale.github.io/cvmfs-tutorial-hpc-best-practices/access/proxy/#client-system-configuration).



## Deploying Squid using the appliance
If an external squid is not available, one can be deployed by the cluster on a
dual-homed host. See [docs/networks.md#proxies](../networks.md#proxies) for
guidance, but note a separate host should be used rather than a Slurm node, to
avoid users on that node getting direct access.

If the deploy host is RockyLinux, this could be used as the squid host by adding
it to inventory:

```ini
# environments/$ENV/inventory/squid
[squid]
# configure squid on deploy host
localhost ansible_host=10.20.0.121 ansible_connection=local
```

The IP address should be the deploy hosts's IP on the cluster network and is used
later to define the proxy address. Other connection variables (e.g. `ansible_user`)
could be set if required.

## Using Squid with basic authentication

First create usernames/passwords on the squid host (tested on RockyLinux 8.9):

```shell
SQUID_USER=rocky
dnf install -y httpd-tools
htpasswd -c /etc/squid/passwords $SQUID_USER # enter pasword at prompt
sudo chown squid /etc/squid/passwords
sudo chmod u=rw,go= /etc/squid/passwords
```

This can be tested by running:
```
/usr/lib64/squid/basic_ncsa_auth /etc/squid/passwords
```

and entering `$SQUID_USER PASSWORD`, which should respond `OK`.

If using the appliance to deploy squid, override the default `squid`
configuration to use basic auth:

```yaml
# environments/$ENV/inventory/group_vars/all/squid.yml:
squid_acls:
    - acl ncsa_users proxy_auth REQUIRED
squid_auth_param: |
    auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/passwords
    auth_param basic children 5
    auth_param basic credentialsttl 1 minute
```

See the [squid docs](https://wiki.squid-cache.org/ConfigExamples/Authenticate/Ncsa) for more information.

## Proxy Configuration

Configure the appliance to configure proxying on all cluster nodes:

```ini
# environments/.stackhpc/inventory/groups:
...
[proxy:children]
cluster
...
```

Now configure the appliance to set proxy variables via remote environment
rather than by writing it to the host, and provide the basic authentication
credentials:

```yaml
#environments/$ENV/inventory/group_vars/all/proxy.yml:
proxy_basic_user: $SQUID_USER
proxy_basic_password: "{{ vault_proxy_basic_password }}"
proxy_plays_only: true
```

```yaml
#environments/$ENV/inventory/group_vars/all/vault_proxy.yml:
vault_proxy_basic_password: $SECRET
```
This latter file should be vault-encrypted.

If using an appliance-deployed squid then the other [proxy role variables](../../ansible/roles/proxy/README.md)
will be automatically constructed (see environments/common/inventory/group_vars/all/proxy.yml).
You may need to override `proxy_http_address` if the hostname of the squid node
is not resolvable by the cluster. This is typically the case if squid is deployed
to the deploy host, in which case the IP address may be specified instead using
the above example inventory as:

```
proxy_http_address: "{{ hostvars[groups['squid'] | first].ansible_host }}"
```

If using an external squid, at a minimum set `proxy_http_address`. You may
also need to set `proxy_http_port` or any other [proxy role's variables](../../ansible/roles/proxy/README.md)
if the calculated parameters are not appropriate.

## Image build

TODO: describe proxy setup for that

## EESSI


## Network considerations

Note that even when outbound internet access is not required, the following
(shown as OpenStack security groups/rules as displayed by Horizon) outbound access from nodes is still required to enable deployment

Assuming nodes have a security group `isolated` applied:

    # allow outbound DNS
    ALLOW IPv4 53/tcp to 0.0.0.0/0
    ALLOW IPv4 53/udp to 0.0.0.0/0
    
    # allow everything within the cluster:
    ALLOW IPv4 from isolated
    ALLOW IPv4 to isolated
    
    # allow hosts to reach metadata server (e.g. for cloud-init keys):
    ALLOW IPv4 80/tcp to 169.254.169.254/32

    # allow hosts to reach squid proxy:
    ALLOW IPv4 3128/tcp to <squid cidr>

Note that DNS is required (and is configured by OpenStack if the subnet has
a gateway) because name resolution happens on the hosts, not on the proxy.

For nodes running OpenOndemand, inbound ssh and https are also required:

    ALLOW IPv4 443/tcp from 0.0.0.0/0
    ALLOW IPv4 22/tcp from 0.0.0.0/0

Note the OpenTofu variables `login_security_groups` and
`nonlogin_security_groups` can be used to set security groups if requried:

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
