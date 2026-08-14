# Site-specific Documentation

## Progress
- working on building new image via new pulp server, old destroyed by DC issues
- working on post-filesystems.yml

## Updates

## Versions
TODO: 

## Environment Overview

This provides for 4x environments:
- `site`: AgR-specific customisations
- TODO: `prd`: Single production cluster
- `stg`: Single staging cluster

The staging and production clusters have:
- A GPFS remotemount for home directories (See `environments/site/hooks/post-filesystems.yml`)
- Nodes enroled with FreeIPA using PKINIT, i.e. certs/keys.
- Cluster state (slurmdbd, slurmctld, monitoring etc) persisted via Cinder volumes
  attached to the control node, which are not deleted if the cluster is deleted.
- Remote state for OpenTofu (i.e. infrastructure) in GitLab.

TODO: Set protected environments

## Access
TODO

## Deployment etc
TODO

## Prexisting OpenStack Resources

The following are required and are **not** defined by the appliance:

All environments:
- Secgroups `SSH`, `HTTPS`, and `HTTP`
- Required networks and subnets - see section below
- Pulp: A VM must be manually deployed for Pulp, e.g.:

    ```shell
    nic_vlan112=$(openstack port create -f value -c id --network nesi-hpc-baremetal-vlan112 --fixed-ip ip-address=10.1.112.99 slurm-pulp-vlan112)
    nic_vlan107=$(openstack port create -f value -c id --network agr-vlan107 --fixed-ip ip-address=10.29.107.113 slurm-pulp-vlan107)
    openstack server create --key-name rocky_bastion_v2 \
        --image Rocky-8-GenericCloud-Base-8.9-20231119.0.x86_64.qcow2 \
        --flavor agr.memory1.2cpu8ram \
        --port $nic_vlan112 \
        --port $nic_vlan107 \
        slurm-pulp
    ```
    Notes:
    - This is shared between all clusters and will be configured by the appliance.
    - It uses a RL8 image for consistency with the clusters.
    - It is on vlan107 to give it direct internet access and vlan112 to allow
      access from the clusters
    - See docs/experimental/pulp.md for subsequent configuration steps

Production and staging environments only:

- GitLab OpenTofu remote states TODO
- Keypair as defined in `environments/site/tofu/variables.tf` TODO AND LOCAL PRIVATE KEY
- Upstream RL8 image as defined in `environments/.stackhpc/tofu/cluster_image.auto.tfvars.json`, converted to RAW and with properties set using `dev/image-set-properties.sh $IMAGE_NAME` TODO add image
 pull
- Volumes for state:

    ```shell
    openstack volume create --type ceph-ssd --size 10 staging-state
    openstack volume create --type ceph-ssd --size 150 eri-state
    ```

- Spectrum Scale installer in clouds's s3-compatible storage. See variable
  `spectrum_scale_installer_s3path`.

## Image build
To try to make image build reasonably efficient without pushing massive GPU
images to every node, this is split into various stages described below.

Each build creates a VM on the `vlan-112` network; ssh configuration for access
is defined in `environments/site/common.pkrvars.hcl`.

### base
The base image installs NVIDIA DOCA-OFED, the FreeIPA client, and Spectrum Scale.
This should only need to be rebuilt when pulling in a new upstream release changes
the upstream image (in environments/.stackhpc/tofu/cluster_image.auto.tfvars.json).
As it will be used as the source image for subsequent stages, it produces a raw
image.

To build this run, from the repo root:

```shell
packer build -color=false -on-error=ask \
    -var-file=environments/site/common.pkrvars.hcl \
    -var-file=environments/site/base.pkrvars.hcl \
    packer/openstack.pkr.hcl | tee environments/site/base.build.log
```

then set properties:

```shell
dev/image-set-properties.sh openhpc-agr-base...
```

TODO: where should the output image be set?

TODO: subsequent stages - extra packages (for non-GPU nodes - qcow2), gpu (qcow2)


## Networking

All nodes are on the `nesi-hpc-baremetal-vlan112` network. Login/OnDemand nodes
are also on the `agr-vlan107` network. For `prd` and `stg` clusters fixed IPs
are allocated with the last tuple as shown below:

| Nodes       |  vlan112 | vlan107 | IPs for prd, stg
| ----------- |--------- | ------- | -------
| control     |  Y       | ?       | .10, .100
| login       |  Y       | Y       | .2*, .12*,
| ondemand    |  Y       | Y       | .30, .130
| baremetal   |  Y       | -       | .4*, .14*
| interactive | Y        | -       | .5*, .150*
| hugemem     | Y        | -       | .6*, .160*
| gpu         | Y        | -       | .7*, .170*
| vmgpu       | Y        | -       | .8*, .180*

TODO: squid? Will have to think about eessi too!

TODO: For dev, can we just start at e.g. 200 and go up consecutivly??

Note no floating IPs are used.

In addition a number of service VMs have ports on the same network:
- Pulp (10.1.112.99): Manually provisioned, but configured via the appliance and
  used by all environments.
    TODO: Also has other ports, could get rid of these once moved over
- Coldfront production (10.1.112.178, 10.29.107.178,): Provisioned/configured outside the appliance.
- Bastion (10.1.112.119, 10.29.107.161): TODO, might go
- Squid:
    - should have prod/staging ones if needed
- jumphost?

Things to copy across:
- TF state
- Secrets


Integrations:

- freeipa via pkinit keys
- gpfs
- 




## Features
