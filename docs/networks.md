# Networking

The default OpenTofu configurations in the appliance do not provision networks,
subnets or associated infrastructure such as routers. The requirements are that:
1. At least one network exists.
2. The first network defined spans all nodes, referred to as the "access network".
3. Only one subnet per network is attached to nodes.
4. At least one network on each node provides outbound internet access (either
directly, or via a proxy).

Addresses on the "access network" used as the `ansible_host` IPs.

It is recommended that the deploy host either has a direct connection to the
"access network" or jumps through a host on it which is not part of the appliance.
Using e.g. a floating IP on a login node as a jumphost creates problems in
recovering the cluster if the login node is unavailable and can make Ansible
problems harder to debug.

> [!WARNING]
> If home directories are on a shared filesystem with no authentication (such
> as the default NFS share) then the network(s) the fileserver is attached to
> form a security boundary. If an untrusted user can access these networks they
> could mount the home directories setting any desired uid/gid.
>
> Ensure there is no external access to these networks and that no untrusted
> instances are attached to them.

This page describes supported configurations and how to implement them using
the OpenTofu variables. These will normally be set in
`environments/site/tofu/terraform.tfvars` for the site base environment. If they
need to be overriden for specific environments, this can be done via an OpenTofu
module as discussed [here](./production.md).

Note that if an OpenStack subnet has a gateway IP defined then by default nodes
with ports attached to that subnet get a default route set via that gateway.

## Single network
This is the simplest possible configuration. A single network and subnet is
used for all nodes. The subnet provides outbound internet access via the default
route defined by the subnet gateway (often an OpenStack router to an external
network).

```terraform
cluster_networks = [
  {
    network = "netA"
    subnet = "subnetA"
  }
]
...
```

## Multiple homogenous networks
This is similar to the above, except each node has multiple networks. The first
network, "netA" is the access network. Note that only one subnet must have a
gateway defined, else default routes via both subnets will be present causing
routing problems. It also shows the second network (netB) using direct-type
vNICs for RDMA.

```terraform
cluster_networks = [
  {
    network = "netA"
    subnet = "subnetA"
  },
  {
    network = "netB"
    subnet = "subnetB"
  },
]

vnic_types = {
    netB = "direct"
}
...
```


## Additional networks on some nodes

This example shows how to modify variables for specific node groups. In this
case a baremetal node group has a second network attached. Here "subnetA" must
have a gateway IP defined and "subnetB" must not, to avoid routing problems on
the multi-homeed compute nodes.

```terraform
cluster_networks = [
  {
    network = "netA"
    subnet = "subnetA"
  }
]

compute = {
  general = {
    nodes = ["general-0", "general-1"]
  }
  baremetal = {
    nodes = ["baremetal-0", "baremetal-1"]
    extra_networks = [
      {
        network = "netB"
        subnet = "subnetB"
      }
    ]
    vnic_types = {
        netA = "baremetal"
        netB = "baremetal"
    ...
    }
  }
}
...
```

## Multiple networks with non-default gateways

In some multiple network configurations it may be necessary to manage default
routes rather than them being automatically created from a subnet gateway.
This can be done using the tofu variable `gateway_ip` which can be set for the
cluster and/or overriden on the compute and login groups. If this is set:
- a default route via that address will be created on the appropriate interface
  during boot if it does not exist
- any other default routes will be removed

For example the cluster configuration below has a "campus" network with a
default gateway which provides inbound SSH / ondemand access and outbound
internet  attached only to the login nodes, and a "data" network attached to
all nodes. The "data" network has no gateway IP set on its subnet to avoid dual
default routes and routing conflicts on the multi-homed login nodes, but does
have outbound connectivity via a router:

```terraform
cluster_networks = [
  {
    network = "data" # access network, CIDR 172.16.0.0/23
    subnet = "data_subnet"
  }
]

login = {
  interactive = {
    nodes = ["login-0"]
    extra_networks = [
      {
        network = "campus"
        subnet = "campus_subnet"
      }
    ]
  }
}
compute = {
  general = {
    nodes = ["compute-0", "compute-1"]
  }
  gateway_ip =  "172.16.0.1" # Router interface
}
```

When using a subnet with no default gateway, OpenStack's nameserver for the
subnet may refuse lookups. External nameservers can be defined using the
[resolv_conf](../ansible/roles/resolv_conf/README.md) role.

## Proxies

If some nodes have no outbound connectivity via any networks, the cluster can
be configured to deploy a [squid proxy](https://www.squid-cache.org/) on a node
with outbound connectivity. Assuming the `compute` and `control` nodes have no
outbound connectivity and the `login` node does, the minimal configuration for
this is:

```yaml
# environments/$SITE/inventory/groups:
[squid:children]
login
[proxy:children]
control
compute
```

```yaml
# environments/$SITE/inventory/group_vars/all/squid.yml:
# these are just examples
squid_cache_disk: 1024 # MB
squid_cache_mem: '12 GB'
```

Note that name resolution must still be possible and may require defining an
nameserver which is directly reachable from the node using the
[resolv_conf](../ansible/roles/resolv_conf/README.md)
role.
