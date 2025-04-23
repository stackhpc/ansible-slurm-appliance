# vGPU/MIG configuration

This page details how to configure Multi Instance GPU (MIG) in Slurm.

## Pre-requisites

- Image built with cuda support. This should automatically recompile slurm against NVML.

## Inventory

Add relevant hosts to the ``vgpu`` group, for example in ```environments/$ENV/inventory/groups``:

```
[vgpu:children]
cuda
```

## Configuration

Use variables from the [stackhpc.linux.vgpu](https://github.com/stackhpc/ansible-collection-linux/tree/main/roles/vgpu) role.

For example in: `environments/<environment>/inventory/group_vars/all/vgpu`:

```
---
vgpu_definitions:
    - pci_address: "0000:17:00.0"
      mig_devices:
        "1g.10gb": 4
        "4g.40gb": 1
    - pci_address: "0000:81:00.0"
      mig_devices:
        "1g.10gb": 4
        "4g.40gb": 1
```

The appliance will use the driver installed via the ``cuda`` role. Use ``lspci`` to determine the PCI
addresses.

## compute_init

Use the ``vgpu`` metadata option to enable creation of mig devices on rebuild.

## gres configuration

Enable gres autodetection. This can be set as a host or group var.

```
openhpc_gres_autodetect: nvml
```

You should stop terraform templating out partitions.yml and specify `openhpc_slurm_partitions` manually.
An example of specifying gres resources is shown below
(`environments/<environment>/inventory/group_vars/all/partitions-manual.yml`):

```
openhpc_slurm_partitions:
    - name: cpu
    - name: gpu
      gres:
        # Two cards not partitioned with MIG
        - conf: "gpu:nvidia_h100_80gb_hbm3:2"
        - conf: "gpu:nvidia_h100_80gb_hbm3_4g.40gb:2"
        - conf: "gpu:nvidia_h100_80gb_hbm3_1g.10gb:6"
```
