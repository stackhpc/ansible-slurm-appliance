# Isolated Clusters

This document explains how to create clusters which do not have outbound internet
access by default.

The approach is to:
- Create a squid proxy with basic authentication and add a user.
- Configure the appliance to set proxy environment variables via Ansible's
  [remote environment support](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_environment.html).

This means that proxy environment variables are not present on the hosts at all
and are only injected when running Ansible, meaning the basic authentication
credentials are not exposed to cluster users.

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

TODO: probably not currently functional!

## EESSI

Although EESSI will install with the above configuration, as there is no
outbound internet access except for Ansible tasks, making it functional will
require [configuring a proxy for CVMFS](https://multixscale.github.io/cvmfs-tutorial-hpc-best-practices/access/proxy/#client-system-configuration).

## Isolation Using Security Group Rules

The below shows the security groups/rules (as displayed by Horizon ) which can
be used to "isolate" a cluster when using a network which has a subnet gateway
provided by a router to an external network. It therefore also indicates what
access is required for a different networking configuration.

Security group `isolated`:

    # allow outbound DNS
    ALLOW IPv4 53/tcp to 0.0.0.0/0
    ALLOW IPv4 53/udp to 0.0.0.0/0
    
    # allow everything within the cluster:
    ALLOW IPv4 from isolated
    ALLOW IPv4 to isolated
    
    # allow hosts to reach metadata server (e.g. for cloud-init keys):
    ALLOW IPv4 80/tcp to 169.254.169.254/32

    # allow hosts to reach squid proxy:
    ALLOW IPv4 3128/tcp to 10.179.2.123/32

Security group `isolated-ssh-https` allows inbound ssh and https (for OpenOndemand):

    ALLOW IPv4 443/tcp from 0.0.0.0/0
    ALLOW IPv4 22/tcp from 0.0.0.0/0


Then OpenTofu is configured as:


    login_security_groups = [
        "isolated",  # allow all in-cluster services
        "isolated-ssh-https",      # access via ssh and ondemand
    ]
    nonlogin_security_groups = [
        "isolated"
    ]

Note that DNS is required (and is configured by the cloud when the subnet has
a gateway) because name resolution happens on the hosts, not on the proxy.
