# Networking

The default OpenTofu configurations in the appliance do not provision networks,
subnets or associated infrastructure such as routers. The requirements are that:
1. At least one network exists.
2. The first network defined spans all nodes, referred to as the "access network".
3. Only one subnet per network is attached to nodes.
4. At least one network on each node provides outbound internet access (either
directly, or via a proxy).

Futhermore, it is recommended that the deploy host's SSH access to the cluster
does not use a cluster node as an SSH proxy, as this can create problems in
recovering the cluster if the login node is unavailable and can make Ansible
problems harder to debug.

This page describes supported configurations and how to implement them using
the OpenTofu variables. These will normally be set in
`environments/site/tofu/terraform.tfvars` for the site base environment. If they
need to be overriden for specific environments, this can be done via an OpenTofu
module as discussed [here](./production.md).

Note that if an OpenStack subnet has a gateway IP defined then nodes with ports
attached to that subnet will get a default route set via that gateway.

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

This example shows how to modify variables for specific node groups. Here the
baremetal node group has a second network attached. In this case "subnetA"
must have a gateway IP defined and "subnetB" must not, to avoid routing
problems on the multi-homed hosts.

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


## Multiple networks - no gateway

In some multiple network configurations it may not be possible for all nodes to
get a default route from a subnet gateway. For example:

```terraform
cluster_networks = [
  {
    network = "netA"
    subnet = "subnetA"
  }
]

login = {
  interactive = {
    nodes = ["login-0"]
    extra_networks = [
      network = "netB"
      subnet = "subnetB"
    ]
  }
}

compute = {
  general = {
    nodes = ["compute-0", "compute-1"]
  }
}
...
```

produces a cluster where the login node(s) have an extra network:

```
           netA   netB
            |      |
login-N ----x------x
            |
control ----x
            |
compute-N --x
```

Commonly here "netA" would be a high-speed network and "netB" might be a campus
network providing outbound internet and inbound SSH / OpenOndemand traffic.
In this case "subnetB" may need to have a default gateway, meaning "subnetA"
cannot to avoid routing problems on the login node(s). The options are then:

1. If "subnetA" has outbound connectivity (e.g. via a router), set the OpenTofu
   variable `gateway_ip` (or equivalent compute group parameter) to the IP to
   use. On first boot, any nodes without a default route will have a persistent
   default route configured via that address using the interface on the access
   network. E.g. setting:

    ```terraform
    ...
    gateway_ip = "10.20.0.1"
    ...
    ```

    will add a default route via `10.20.0.1` to the control and compute nodes,
    ignoring the login node(s) which already get a default route via the gateway
    defined on "subnetB".

2. If "subnetB" does not have outbound connectivity, this can be provided for
   the control and compute nodes by configuring a caching proxy on a node
   which does have direct outbound connectivity. For the above cluster the
   minimal configuration for this is:

      ```yaml
      # environments/$SITE/inventory/groups:
      [squid:children]
      login

      [proxy:children]
      control
      compute
      ```

      ```yaml
      # environments/$SITE/inventory/group_vars/all/squid:
      squid_cache_disk: 1024 # MB
      squid_cache_mem: "12 GB"
      ```
  In this case, for the nodes only on "netB" a dummy default route is
  automatically configured [to ensure](https://docs.k3s.io/installation/airgap#default-network-route)
  proper `k3s` operation.
