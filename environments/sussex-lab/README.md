# Sussex-Lab cluster

Configuration for the Sussex lab environment on Leafcloud. This is intended to provide
Sussex staff with a functional cluster.

# Required resources
The following resources must be manually provisioned before deployment:
- Volumes named `sussexlab-state` and `sussexlab-home`
- A FIP; the address must be set as the `fip` attribute for the login node in Tofu variable
`login_nodes`.
- Networks `sussex_tenant` and `sussex_storage` and subnets with the same names and an
external router with interfaces on both subnets. **NB:** The `sussex_storage` subnet
must NOT have a default gateway.

# Cluster Overview

Resources marked `*` below are **not** defined in the Tofu configuration and hence
persist if the cluster is deleted.

```
 │    sussex-tenant*      sussex-storage*     
 │ ┌──┐ │                  │
 │ │  ├────────────────────┤ ┌─────────┐   
 ├─┤X*├─┤  ┌ SSH/HTTPS     ├─┤nfs      │   
 │ └──┘ │ ┌┴──────┐        │ └┬────────┘   
 │      ├─┤login-0├────────┤  └─home-volume*
        │ └───────┘        │
          ┌───────┐        │
          |control├────────┤
          └┬──────┘        │
           └─state-volume* │ ┌─────────┐   
                           ├─┤compute-0│   
                           │ └─────────┘   
                           │ ┌─────────┐   
                           ├─┤compute-1│   
                           │ └─────────┘ 
```

- The `sussex-tenant` network models an OpenStack tenant network. The default gateway is
the router interface connecting to the external network.
- The `sussex-storage` network models a provider network with routing to NFS/lustre.
On the production system this may have outbound internet via the campus network or this
may be provided via a squid proxy on the control node. For simplicity in the lab
environment the router has an interface on this subnet (hence why the default gateway
must be disabled on this subnet to avoid routing loops) and the gateway is added via
Ansible.
- The login node has a FIP with SSH and HTTPS enabled and runs fail2ban. It also proxies
Grafana via OOD.
- All nodes use `/etc/hosts` for cluster name resolution.
- In lieu of actual Sussex NFS/lustre access, the appliance is configured to provision
an NFS server on the storage network. This will export directories from an OpenStack
volume (Manila is not available). This volume will persist on lab cluster deletion.
- Two compute nodes are provided to allow testing inter-node MPI etc.
- User definition is templated via the `basic_users` role. Only a user for
`reese.wilkinson` will be initially configured and has sudo rights. Note to allow this
user to access the control node this node must mount /home.
- The `/var/lib/state` directory on the control node (mounted on an Openstack volume) is
exported to the login node to allow the `persist_hostkeys` role to be used.
- The cluster uses an OFED image.
- CI is disabled as although the repo is in the stackhpc organisation it does not have
access to secrets.

