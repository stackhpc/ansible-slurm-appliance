# Networks

The default OpenTofu configurations in the appliance do not provision networks,
subnets or associated infrastructure such as routers. The requirements are that:
1. At least one network exists.
2. At least one network spans all nodes, referred to as the "access network".
3. Only one subnet per network is attached to nodes.
4. At least one network on each node provides outbound internet access (either directly,
  or via a proxy).

Futhermore, it is recommended that the deploy host has an interface on the
access network. While it is possible to e.g. use a floating IP on a login node
as an SSH proxy to access the other nodes, this can create problems in recovering
the cluster if the login node is unavailable and can make Ansible problems harder
to debug.

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
This is similar to the above, except each node has multiple networks. Therefore
`access_network` must be explicitly set. Note that only one subnet must have
a gateway defined, else default routes via both subnets will be present causing
routing problems. It also shows the second network (netB) using direct-type vNICs
for RDMA.

```terraform
cluster_networks = [
  {
    network = "netA"
    subnet = "subnetA"
    access_network = true
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

This example shows how to override variables for specific node groups. In this
case a baremetal node group has a second network attached. As above, only a
single subnet can have a gateway IP.

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
    networks = [
      {
        network = "netA"
        subnet = "subnetA"
        access_network = true
      },
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
...
```
