# Site-specific Documentation

## WIP NOTES

### Progress
- all works through to post hook
- need to do monitoring
- need to do post-monitoring hook
- and actually check ondemand

### Production
Things to copy across:
- TF state
- Secrets

Will have to change the `compute` group to a different name ...
TODO: Set protected environments

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

There is also integration against Reannz's observability platform (Mimir and Loki)
- see [docs](./README_external_observability.md).

## Cluster Access

Access to the cluster for all is through the interfaces on `agr-vlan107` -
there are no floating IPs:
- stg:
    login: 10.29.107.120 TODO FQDN
    ondemand: 10.29.107.130 TODO FQDN
- prd: TODO

Access for Ansible and admin uses the `rocky` user via a jumphost:
`rocky@slurm-bastion.eri.agresearch.co.nz`. The cluster uses the keypair
`rocky_bastion_v2`.

See below for suggested checkout configuration for Ansible.

## Deployment etc

The instructions here assume a local checkout will be used, rather than
a shared checkout on the jumphost. This is the preferred configuration as it
avoids confusing shared checkout state.

### One-time setup

1. Install python 3.12 and OpenTofu.

2. Create a project access token and use this to clone the repository locally:

```
export GITLAB_PAT='<your token secret>'
git clone https://token:${GITLAB_PAT}@gitlab.com/nesi1/agresearch/agr-eri-slurm.git
```

3. Retrieve ssh keys for the jumphost and cluster from your password manager

### Use

1. Checkout whichever branch is relevant

2. Refresh the repo's dependencies:

  ```shell
  dev/setup-env.sh
  ```

3. Configure your environment. The details of this depend on file locations:

  ```shell
  # load python
  . venv/bin/activate
  
  # make credentials available
  export OS_CLIENT_CONFIG_FILE=$(realpath path_to_clouds.yaml)
  export OS_CLOUD=openstack
  export ANSIBLE_VAULT_PASSWORD_FILE=$(realpath path_to_vault_password)
  export TF_VAR_gitlab_access_token=${GITLAB_PAT}
  
  # setup ssh
  export ANSIBLE_SSH_COMMON_ARGS="-i $(realpath $path_to_jumphost_private_key) -J nesi-ansible"
  export PKR_VAR_ssh_private_key_file=$(realpath $path_to_cluster_private_key)
  export PKR_VAR_ssh_bastion_private_key_file=$(realpath $path_to_jumphost_private_key)
  ssh-add ${path_to_cluster_private_key}

4. Activate the relevant appliance environment, e.g.:

  ```shell
  . environments/stg/activate
  ```

5. If necessary, check/apply infrastructure changes:

  ```shell
  tofu apply
  ```

  NB: This should be run from the repository root - you no longer need to
  change to the relevant `tofu/` directory.

6. Configure the cluster:

  ```shell
  ansible-playbook ansible/site.yml
  ```

## Recovering GPFS

This seems to be flaky; when it loses the mounts it seems to need rebooting
the node(s) then running:

```shell
ansible-playbook environments/site/hooks/post-filesystems.yml -e scale_remotemount_forceRun=true
```

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

Builds use the same ssh key as the cluster for convenience in debugging.

Each build is defined by a pkrvars file in `environments/site/<image>.pkrvars.hcl`
- all builds also the `common.pkrvars.hcl` file there too.

The following image build are defined:
- `base`: This installs NVIDIA DOCA-OFED, FreeIPA and Spectrum Scale clients
  on top of the upstream StackHPC release images. It should only need to be
  rebuilt when pulling in a new upstream release changes the upstream image defined
  in `environments/.stackhpc/tofu/cluster_image.auto.tfvars.json`. It is only
  used for further builds and is not referenced from OpenTofu configurations.
- `std`: This installs additional site-specific packages and OpenOndemand
  server-side apps on top of the `base` build. It is used for VM and BM non-GPU
  control/login/compute nodes. It should be set as the default cluster image for
  all environments using `cluster_image_id` in `environments/site/tofu/variables.tf`.
- `gpu`: This installs additional site-specific packages, NVIDIA drivers
  and cuda packages on top of the `base` build. It is used for VM and BM GPU
  compute nodes. It should be set as the image for each relevant node group
  using the `image_id` override in the environment-specific `environments/*/tofu/main.tf`.


### Initial setup

Builds require the RockyLinux 8 StackHPC release image
as given in `environments/.stackhpc/tofu/cluster_image.auto.tfvars.json` for
the appropriate branch to be available on the cloud. E.g.:

```shell
STACKHPC_IMAGE=$(jq --raw-output .cluster_image.RL8 environments/.stackhpc/tofu/cluster_image.auto.tfvars.json)
wget https://leafcloud.store/swift/v1/AUTH_f39848421b2747148400ad8eeae8d536/openhpc-images/$STACKHPC_IMAGE
qemu-img convert -O raw $STACKHPC_IMAGE $STACKHPC_IMAGE.raw
qemu-img info $STACKHPC_IMAGE $STACKHPC_IMAGE.raw
openstack image create --file $STACKHPC_IMAGE.raw --disk-format=raw --min-disk 20 $STACKHPC_IMAGE
dev/image-set-properties.sh $STACKHPC_IMAGE
```

The Pulp server must have the DNF repo snapshots for the current branch synced:

```shell
ansible-playbook ansible/adhoc/sync-pulp.yml
```

### Building an image

**NB:** All builds should be run with the `stg` environment activated.

1. Update the `source_image_name` in the relevant pkrvars file in 
   `environments/site/$BUILD.pkrvars.hcl`
   and commit that.

2. Build the image:

  ```shell
  dev/image-build $BUILD
  ```

  where `$BUILD` is the build name as above, e.g. `base`.

  This will log to stdout and also `environments/site/$BUILD.build.log`.

  Make a note of the image name and ID output at the end of the log.

3. Commit the log file.

4. Set image properties:

  ```shell
  dev/image-set-properties.sh <image name or id>
  ```

5. Update the source image for the next image in the chain in its pkrvars file.

6. Where relevant, update the OpenTofu config with the new image ID.

7. Commit changes for 5/6.

## Networking

All nodes are on the `nesi-hpc-baremetal-vlan112` network. Login/OnDemand nodes
are also on the `agr-vlan107` network. For `prd` and `stg` clusters fixed IPs
are allocated with the last tuple as shown below:

| Nodes       | vlan112  | vlan107 | IPs for prd, stg
| ----------- |--------- | ------- | -------
| control     | Y        | ?       | .10, .100
| login       | Y        | Y       | .2*, .12*,
| ondemand    | Y        | Y       | .30, .130
| baremetal   | Y        | -       | .4*, .14*
| interactive | Y        | -       | .5*, .150*
| hugemem     | Y        | -       | .6*, .160*
| gpu         | Y        | -       | .7*, .170*
| vmgpu       | Y        | -       | .8*, .180*

Note no floating IPs are used.

All compute nodes are proxied through a (non-appliance-controlled) squid on the
jumphost. EESSI is proxied through squid on the control node, as per default.

TODO: For dev, can we just start at e.g. 200 and go up consecutivly??

In addition a number of service VMs have ports on the same network:
- Pulp (10.1.112.99): Manually provisioned, but configured via the appliance and
  used by all environments.
    TODO: Also has other ports, could get rid of these once moved over
- Coldfront production (10.1.112.178, 10.29.107.178,): Provisioned/configured outside the appliance.
- Jumphost (10.1.112.119, 10.29.107.161)
