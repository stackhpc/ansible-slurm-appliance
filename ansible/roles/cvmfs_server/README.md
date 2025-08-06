# cvmfs_server

Install a CernVM-FS Stratum 1 server replicating the EESSI repository.

By default, the appliance `eessi` role configures EESSI clients to use EESSI's
Stratum 1 servers. If EESSI is in production use, the `squid` role should normally
be configured to provide an http proxy for those clients to reduce the load
on the upstream stratum 1 servers. However both of those approaches assume that
there is outbound http access. If this is not the case, this role can be used
to provide a private, in-cluster server replicating the EESSI repository from
an EESSI synchronisation server.

This feature is enabled by adding a node to the `cvmfs_server` group. The
defaults provided are sufficent to implement the above configuration.

This role wraps the [EESSI ansible-cvmfs](https://github.com/EESSI/ansible-cvmfs)
role which provides additional functionality. Because of the intended use of
this role by default it:
- Uses https URLs for both dnf repositories and for the EESSI repository replication.
- Uses the `aws-eu-west-s1-sync` EESSI server (which is the only one providing
  https replication).
- Does not configure a squid proxy in front of the Stratum 1 server.
- Does not configure a firewall (OpenStack security groups are expected to be
  sufficent).
- Does not configure the Geo API service.

Guidance on configuring a private Stratum 1 server for EESSI is provided [here](https://www.eessi.io/docs/filesystem_layer/stratum1/#requirements-for-a-stratum-1).

# Requirements

See also the example configuration below.

1. See the [EESSI Stratum 1 requirements](https://www.eessi.io/docs/filesystem_layer/stratum1/#requirements-for-a-stratum-1)
   for the server specification.
3. The node used must have outbound connectivity for dnf package installs
   and to replicate the EESSI repository.
4. If this role is used to provide EESSI for an [isolated cluster](../../../docs/experimental/isolated-clusters.md)
   where cluster users have no outbound internet connectivity, ensure those users
   cannot access this node, i.e. it is not in groups `basic_user`, `ldap` or
   `freeipa`.
5. The node is automatically added to the `dnf_repos` group to enable yum
   repositories so this role can install dependencies. It therefore requires
   either configuring Ark credentials or a local Pulp server - see links in
   [adding additional packages](../../../docs/operations.md#adding-additional-packages).
   Note the former will also require setting `dnf_repos_allow_insecure_creds: true`
   to allow Ark credentials to be templated into repofiles - this also requires 3.
   to avoid exposing these to cluster users.
 
## Role variables

Any variables from the [EESSI ansible-cvmfs role](https://github.com/EESSI/ansible-cvmfs)
may be used. Due to wrapping that role, this role's defaults are mostly in
`environments/common/inventory/group_vars/all/cvmfs_server.yml`. The only
override likely to be be needed is to set `cvmfs_srv_device` if CVMFS data
should be be stored on a specific block device (e.g. a mounted volume).

## Example configuration

The below OpenTofu configuration creates a new node in the `cvmfs_server` group
with a new 1TB volume attached:

```terraform
# environments/production/tofu/main.tf:
module "cluster" {

  ... 

  additional_nodegroups = {
    cvmfs_server = {
      nodes = ["eessi"]
      flavor = "m2.medium"
      extra_volumes = {
        srv = {
          size = 1000 # GB
        }
      }
    }
  }

  ...
}
```

Configure the role to use the volume for CVMFS data:

```
# environments/site/inventory/group_vars/all/cvmfs_server.yml:
cvmfs_srv_device: /dev/vdb
```

**NB:** Hardcoding the path is only safe if a single volume is attached, else
the ordering of devices is not guaranteed after reboots etc.

Note Ark credentials or a local Pulp server must also be configured as referenced
above.

## Client configuration

Configuration for EESSI clients is provided by the [eessi](../eessi/README.md)
role. To use the Stratum 1 server provided by this role requires overriding
the default configuration (NB: not adding additional configuration) using:

```
# environments/site/inventory/group_vars/all/eessi.yml:
cvmfs_config:
  CVMFS_SERVER_URL: "http://{{ hostvars[groups['cvmfs_server'] | first].ansible_host }}/cvmfs/@fqrn@"
```
