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

The appliance will use the driver installed via the ``cuda`` role. 

Use ``lspci`` to determine the PCI addresses e.g:

```
[root@io-io-gpu-02 ~]# lspci -nn | grep -i nvidia
06:00.0 3D controller [0302]: NVIDIA Corporation GH100 [H100 SXM5 80GB] [10de:2330] (rev a1)
0c:00.0 3D controller [0302]: NVIDIA Corporation GH100 [H100 SXM5 80GB] [10de:2330] (rev a1)
46:00.0 3D controller [0302]: NVIDIA Corporation GH100 [H100 SXM5 80GB] [10de:2330] (rev a1)
4c:00.0 3D controller [0302]: NVIDIA Corporation GH100 [H100 SXM5 80GB] [10de:2330] (rev a1)
```

The supported profiles can be discovered by consulting the [NVIDIA documentation](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/index.html#supported-mig-profiles)
or interactively by running the following on one of the compute nodes with GPU resources:

```
[rocky@io-io-gpu-05 ~]$ sudo nvidia-smi -i 0 -mig 1
Enabled MIG Mode for GPU 00000000:06:00.0
All done.
[rocky@io-io-gpu-05 ~]$ sudo nvidia-smi mig -lgip
+-----------------------------------------------------------------------------+
| GPU instance profiles:                                                      |
| GPU   Name             ID    Instances   Memory     P2P    SM    DEC   ENC  |
|                              Free/Total   GiB              CE    JPEG  OFA  |
|=============================================================================|
|   0  MIG 1g.10gb       19     7/7        9.75       No     16     1     0   |
|                                                             1     1     0   |
+-----------------------------------------------------------------------------+
|   0  MIG 1g.10gb+me    20     1/1        9.75       No     16     1     0   |
|                                                             1     1     1   |
+-----------------------------------------------------------------------------+
|   0  MIG 1g.20gb       15     4/4        19.62      No     26     1     0   |
|                                                             1     1     0   |
+-----------------------------------------------------------------------------+
|   0  MIG 2g.20gb       14     3/3        19.62      No     32     2     0   |
|                                                             2     2     0   |
+-----------------------------------------------------------------------------+
|   0  MIG 3g.40gb        9     2/2        39.50      No     60     3     0   |
|                                                             3     3     0   |
+-----------------------------------------------------------------------------+
|   0  MIG 4g.40gb        5     1/1        39.50      No     64     4     0   |
|                                                             4     4     0   |
+-----------------------------------------------------------------------------+
|   0  MIG 7g.80gb        0     1/1        79.25      No     132    7     0   |
|                                                             8     7     1   |
+-----------------------------------------------------------------------------+
|   1  MIG 1g.10gb       19     7/7        9.75       No     16     1     0   |
|                                                             1     1     0   |
+-----------------------------------------------------------------------------+
|   1  MIG 1g.10gb+me    20     1/1        9.75       No     16     1     0   |
|                                                             1     1     1   |
+-----------------------------------------------------------------------------+
|   1  MIG 1g.20gb       15     4/4        19.62      No     26     1     0   |
|                                                             1     1     0   |
+-----------------------------------------------------------------------------+
|   1  MIG 2g.20gb       14     3/3        19.62      No     32     2     0   |
|                                                             2     2     0   |
+-----------------------------------------------------------------------------+
|   1  MIG 3g.40gb        9     2/2        39.50      No     60     3     0   |
|                                                             3     3     0   |
+-----------------------------------------------------------------------------+
|   1  MIG 4g.40gb        5     1/1        39.50      No     64     4     0   |
|                                                             4     4     0   |
+-----------------------------------------------------------------------------+
|   1  MIG 7g.80gb        0     1/1        79.25      No     132    7     0   |
|                                                             8     7     1   |
+-----------------------------------------------------------------------------+
|   2  MIG 1g.10gb       19     7/7        9.75       No     16     1     0   |
|                                                             1     1     0   |
+-----------------------------------------------------------------------------+
|   2  MIG 1g.10gb+me    20     1/1        9.75       No     16     1     0   |
|                                                             1     1     1   |
+-----------------------------------------------------------------------------+
|   2  MIG 1g.20gb       15     4/4        19.62      No     26     1     0   |
|                                                             1     1     0   |
+-----------------------------------------------------------------------------+
|   2  MIG 2g.20gb       14     3/3        19.62      No     32     2     0   |
|                                                             2     2     0   |
+-----------------------------------------------------------------------------+
|   2  MIG 3g.40gb        9     2/2        39.50      No     60     3     0   |
|                                                             3     3     0   |
+-----------------------------------------------------------------------------+
|   2  MIG 4g.40gb        5     1/1        39.50      No     64     4     0   |
|                                                             4     4     0   |
+-----------------------------------------------------------------------------+
|   2  MIG 7g.80gb        0     1/1        79.25      No     132    7     0   |
|                                                             8     7     1   |
+-----------------------------------------------------------------------------+
|   3  MIG 1g.10gb       19     7/7        9.75       No     16     1     0   |
|                                                             1     1     0   |
+-----------------------------------------------------------------------------+
|   3  MIG 1g.10gb+me    20     1/1        9.75       No     16     1     0   |
|                                                             1     1     1   |
+-----------------------------------------------------------------------------+
|   3  MIG 1g.20gb       15     4/4        19.62      No     26     1     0   |
|                                                             1     1     0   |
+-----------------------------------------------------------------------------+
|   3  MIG 2g.20gb       14     3/3        19.62      No     32     2     0   |
|                                                             2     2     0   |
+-----------------------------------------------------------------------------+
|   3  MIG 3g.40gb        9     2/2        39.50      No     60     3     0   |
|                                                             3     3     0   |
+-----------------------------------------------------------------------------+
|   3  MIG 4g.40gb        5     1/1        39.50      No     64     4     0   |
|                                                             4     4     0   |
+-----------------------------------------------------------------------------+
|   3  MIG 7g.80gb        0     1/1        79.25      No     132    7     0   |
|                                                             8     7     1   |
+-----------------------------------------------------------------------------+
```

## compute_init

Use the ``vgpu`` metadata option to enable creation of mig devices on rebuild.

## GRES configuration

You should stop terraform templating out partitions.yml and specify `openhpc_nodegroups` manually. To do this
set the `autogenerated_partitions_enabled` terraform variable to `false`. For example (`environments/production/tofu/main.tf`):

```
module "cluster" {
  source = "../../site/tofu/"
  ...
  # We manually populate this to add GRES. See environments/site/inventory/group_vars/all/partitions-manual.yml.
  autogenerated_partitions_enabled = false
}
```

GPU types can be determined by deploying slurm without any gres configuration and then running
`sudo slurmd -G` on a compute node where GPU resources exist. An example is shown below:

```
[rocky@io-io-gpu-02 ~]$ sudo slurmd -G
slurmd-io-io-gpu-02: Gres Name=gpu Type=nvidia_h100_80gb_hbm3 Count=1 Index=0 ID=7696487 File=/dev/nvidia0 Links=(null) Flags=HAS_FILE,HAS_TYPE,ENV_NVML,ENV_RSMI,ENV_ONEAPI
,ENV_OPENCL,ENV_DEFAULT
slurmd-io-io-gpu-02: Gres Name=gpu Type=nvidia_h100_80gb_hbm3 Count=1 Index=1 ID=7696487 File=/dev/nvidia1 Links=(null) Flags=HAS_FILE,HAS_TYPE,ENV_NVML,ENV_RSMI,ENV_ONEAPI
,ENV_OPENCL,ENV_DEFAULT
slurmd-io-io-gpu-02: Gres Name=gpu Type=nvidia_h100_80gb_hbm3_4g.40gb Count=1 Index=291 ID=7696487 File=/dev/nvidia-caps/nvidia-cap291 Links=(null) Flags=HAS_FILE,HAS_TYPE,
ENV_NVML,ENV_RSMI,ENV_ONEAPI,ENV_OPENCL,ENV_DEFAULT
slurmd-io-io-gpu-02: Gres Name=gpu Type=nvidia_h100_80gb_hbm3_4g.40gb Count=1 Index=417 ID=7696487 File=/dev/nvidia-caps/nvidia-cap417 Links=(null) Flags=HAS_FILE,HAS_TYPE,
ENV_NVML,ENV_RSMI,ENV_ONEAPI,ENV_OPENCL,ENV_DEFAULT
slurmd-io-io-gpu-02: Gres Name=gpu Type=nvidia_h100_80gb_hbm3_1g.10gb Count=1 Index=336 ID=7696487 File=/dev/nvidia-caps/nvidia-cap336 Links=(null) Flags=HAS_FILE,HAS_TYPE,
ENV_NVML,ENV_RSMI,ENV_ONEAPI,ENV_OPENCL,ENV_DEFAULT
slurmd-io-io-gpu-02: Gres Name=gpu Type=nvidia_h100_80gb_hbm3_1g.10gb Count=1 Index=345 ID=7696487 File=/dev/nvidia-caps/nvidia-cap345 Links=(null) Flags=HAS_FILE,HAS_TYPE,
ENV_NVML,ENV_RSMI,ENV_ONEAPI,ENV_OPENCL,ENV_DEFAULT
slurmd-io-io-gpu-02: Gres Name=gpu Type=nvidia_h100_80gb_hbm3_1g.10gb Count=1 Index=354 ID=7696487 File=/dev/nvidia-caps/nvidia-cap354 Links=(null) Flags=HAS_FILE,HAS_TYPE,
ENV_NVML,ENV_RSMI,ENV_ONEAPI,ENV_OPENCL,ENV_DEFAULT
slurmd-io-io-gpu-02: Gres Name=gpu Type=nvidia_h100_80gb_hbm3_1g.10gb Count=1 Index=507 ID=7696487 File=/dev/nvidia-caps/nvidia-cap507 Links=(null) Flags=HAS_FILE,HAS_TYPE,
ENV_NVML,ENV_RSMI,ENV_ONEAPI,ENV_OPENCL,ENV_DEFAULT
slurmd-io-io-gpu-02: Gres Name=gpu Type=nvidia_h100_80gb_hbm3_1g.10gb Count=1 Index=516 ID=7696487 File=/dev/nvidia-caps/nvidia-cap516 Links=(null) Flags=HAS_FILE,HAS_TYPE,
ENV_NVML,ENV_RSMI,ENV_ONEAPI,ENV_OPENCL,ENV_DEFAULT
slurmd-io-io-gpu-02: Gres Name=gpu Type=nvidia_h100_80gb_hbm3_1g.10gb Count=1 Index=525 ID=7696487 File=/dev/nvidia-caps/nvidia-cap525 Links=(null) Flags=HAS_FILE,HAS_TYPE,
ENV_NVML,ENV_RSMI,ENV_ONEAPI,ENV_OPENCL,ENV_DEFAULT
```

GRES resources can then be configured manually. An example is shown below
(`environments/<environment>/inventory/group_vars/all/partitions-manual.yml`):

```
openhpc_partitions:
  - name: cpu
  - name: gpu

openhpc_nodegroups:
    - name: cpu
    - name: gpu
      gres_autodetect: nvml
      gres:
        - conf: "gpu:nvidia_h100_80gb_hbm3:2"
        - conf: "gpu:nvidia_h100_80gb_hbm3_4g.40gb:2"
        - conf: "gpu:nvidia_h100_80gb_hbm3_1g.10gb:6"
```
