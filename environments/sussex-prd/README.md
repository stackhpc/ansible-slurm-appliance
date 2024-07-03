# Sussex Production Environment

# Required resources
The following resources must be manually provisioned before deployment:
- Volumes named `prd-state` and `prd-home`
- A FIP; the address must be set as the `fip` attribute for the login node in Tofu variable
`login_nodes`.
- Networks as defined in the *.tf files. **NB** The storage subnet must not have a default gateway.

# Cluster Overview

Resources marked `*` below are **not** defined in the Tofu configuration and hence
persist if the cluster is deleted.

```
 │    tenant_net*      storage_net*     
 │ ┌──┐ │                  │
 │ │  ├────────────────────┤ ┌─────────┐   
 ├─┤X*├─┤  ┌ SSH/HTTPS     ├─┤nfs      │   
 │ └──┘ │ ┌┴──────┐        │ └┬────────┘   
 │      ├─┤login-0├────────┤  └─home-volume*
        │ └───────┘        │
        | ┌───────┐        │
        ├─┤control├────────┤
          └┬──────┘        │
           └─state-volume* │ ┌─────────┐   
                           ├─┤compute-0│   
                           │ └─────────┘   
                           │ ┌─────────┐   
                           ├─┤compute-1│   
                           │ └─────────┘ 
```

- The `tenant_net` network is an OpenStack tenant network. The default gateway is
  the router interface connecting to the external network.
- The `storage_net` network is a provider network with routing to NFS/lustre.
  This has no default gateway (to avoid routing loops with dual-interfaced nodes) and
  outbound internet is provided via a squid proxy on the control node.
- The login node has a FIP with SSH and HTTPS enabled and runs fail2ban. It also proxies
Grafana via OOD.
- All nodes use `/etc/hosts` for cluster name resolution.
- In lieu of actual Sussex NFS/lustre access at present, the appliance is configured to provision
  an NFS server on the storage network. This will export directories from an OpenStack
  volume (Manila is not available). This volume will persist on lab cluster deletion.
- Two compute nodes are provided to allow testing inter-node MPI etc.
- User definition is templated via the `basic_users` role.
- The `/var/lib/state` directory on the control node (mounted on an Openstack volume) is
exported to the login node to allow the `persist_hostkeys` role to be used.
- The cluster uses an OFED image.
