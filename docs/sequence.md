# Slurm Appliance Sequences



## Image build

This sequence applies to both:
- "fatimage" builds, starting from GenericCloud images and using
  control,login,compute inventory groups to install all packages, e.g. StackHPC
  CI builds
- "extra" builds, starting from StackHPC images and using selected inventory
  groups to add specfic features for a site-specific image.

Note that a generic Pulp server is shown in the below diagram. This may be
StackHPC's Ark server or a local Pulp mirroring Ark. It is assumed a local Pulp
has already had the relevant snapshots synced from Ark (although it is possible
to trigger this during an image build).

Note that ansible-init does not run during an image build. It is disabled via
a metadata flag.

```mermaid
sequenceDiagram
    participant ansible as Ansible Deploy Host
    participant cloud as Cloud
    note over ansible: $ packer build ...
    ansible->>cloud: Create VM
    create participant packer as Build VM
    participant pulp as Pulp
    cloud->>packer: Create VM
    note over packer: Boot
    rect rgb(204, 232, 252)
    note right of packer: ansible-init
    packer->>cloud: Query metadata
    cloud->>packer: Metadata sent
    packer->>packer: Skip ansible-init
    end
    ansible->>packer: Wait for ssh connection
    rect rgb(204, 232, 252)
    note right of ansible: fatimage.yml
    ansible->>packer: Overwrite repo files with Pulp repos and update
    packer->>pulp: dnf update
    pulp-->>packer: Package updates
    ansible->>packer: Perform installation tasks
    ansible->>packer: Shutdown
    end
    ansible->>cloud: Create image from Build VM root disk
    destroy packer
    note over cloud: Image created
```

## Cluster Creation

In the below it is assumed that no additional packages are installed beyond
what is present in the image, i.e. Ark/local Pulp access is not required.

```mermaid
sequenceDiagram
    participant ansible as Ansible Deploy Host
    participant cloud as Cloud
    rect rgb(204, 232, 252)
    note over ansible: $ ansible-playbook ansible/adhoc/generate-passwords.yml
    ansible->>ansible: Template secrets to inventory group_vars
    end
    rect rgb(204, 232, 252)
    note over ansible: $ tofu apply ...
    ansible->>cloud: Create infra
    create participant nodes as Cluster Instances
    cloud->>nodes: Create instances
    end
    note over nodes: Boot
    rect rgb(204, 232, 252)
    note right of nodes: ansible-init
    nodes->>cloud: Query metadata
    cloud->>nodes: Metadata sent
    end
    rect rgb(204, 232, 252)
    note over ansible: $ ansible-playbook ansible/site.yml
    ansible->>nodes: Wait for ansible-init completion
    ansible->>nodes: Ansible tasks
    note over nodes: All services running
    end
```

## Slurm Controlled Rebuild

This sequence applies to active clusters, after running the `site.yml` playbook
for the first time. Slurm controlled rebuild requires that:
- Compute groups in the OpenTofu `compute` variable have:
    - `ignore_image_changes: true`
    - `compute_init_enable: ['compute', ... ]`
- The Ansible `rebuild` inventory group contains the `control` group.

TODO: should also document how compute-init does NOT run if the `site.yml`
playbook has not been run.

```mermaid
sequenceDiagram
    participant ansible as Ansible Deploy Host
    participant cloud as Cloud
    participant nodes as Cluster Instances
    note over ansible: Update OpenTofu cluster_image variable [1]
    rect rgb(204, 232, 250)
    note over ansible: $ tofu apply ....
    ansible<<->>cloud: Check login/compute current vs desired images
    cloud->>nodes: Reimage login and control nodes
    ansible->>ansible: Update inventory/hosts.yml for<br>compute node image_id
    end
    rect rgb(204, 232, 250)
    note over ansible: $ ansible-playbook ansible/site.yml
    ansible->>nodes: Hostvars templated to nfs share
    ansible->>nodes: Ansible tasks
    note over nodes:All services running
    end
    note over nodes: $ srun --reboot ...
    rect rgb(204, 232, 250)
    note over nodes: RebootProgram [2]
    nodes->>cloud: Compare current instance image to target from hostvars
    cloud->>nodes: Reimage if target != current
    rect rgb(252, 200, 100)
    note over nodes: compute-init [3]
    nodes->>nodes: Retrieve hostvars from nfs mount
    nodes->>nodes: Run ansible tasks
    note over nodes: Compute nodes rejoin cluster
    end
    end
    nodes->>nodes: srun task completes
```
Notes:
1. And/or login/compute group overrides
2. Running on control node
3. On hosts targeted by job

