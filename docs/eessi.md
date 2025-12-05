# EESSI Guide

## How to Load EESSI

The EESSI environment can be initialised by running:

```bash
source /cvmfs/software.eessi.io/versions/2023.06/init/bash
```

This is non-reversible because it:

- Changes your `$PATH`, `$MODULEPATH`, `$LD_LIBRARY_PATH`, and other critical environment variables.
- Sets EESSI-specific variables such as `EESSI_ROOT`.

However, it is the recommended method because it:

- Detects system CPU architecture and OS.
- Detects and configures GPU support.
- Prepares the full EESSI software stack.
- Sets up Lmod (environment module system).

The [EESSI docs](https://www.eessi.io/docs/using_eessi/setting_up_environment/) offer another method to load EESSI. This alternative method only initialises the Lmod module system and does not load a platform-specific setup. For these reasons, it is recommended to use the method detailed above.

Successful environment setup will show `{EESSI 2023.06}` at the start of your CLI.

To deactivate your EESSI environment you can either restart your shell using `exec bash` or exit the shell by running `exit`.

## GPU Support with EESSI

To enable GPU support, the cluster must be running a site-specific image build that has CUDA enabled. For a guide on how to do this, please refer to [docs/image-build.md](../image-build.md).

More information about EESSI GPU Support can be found in the [EESSI docs](https://www.eessi.io/docs/site_specific_config/gpu/).

### Using GPUs

All CUDA-enabled software in EESSI expects CUDA drivers in a specific `host_injections` directory.

#### To expose the NVIDIA GPU drivers

Use the `link_nvidia_host_libraries.sh` script, provided by EESSI, to symlink your GPU drivers into `host_injections`.

```bash
/cvmfs/software.eessi.io/versions/2023.06/scripts/gpu_support/nvidia/link_nvidia_host_libraries.sh
```

Rerun this script when your NVIDIA GPU drivers are updated. It is also safe to rerun at any time as the script will detect if the driver versions have already been symlinked.

### Building with GPUs

Run `which nvcc` to confirm that the CUDA compiler is found.

If `nvcc` is not found, add the CUDA path to your environment:

```bash
export PATH=/usr/local/cuda/bin:$PATH
```

`which nvcc` should now show the path to the CUDA compiler.

#### Loading EESSI buildenv module

The `buildenv` module provides the environment needed to build software with EESSI. The module sets up compiler and linker wrappers to ensure the builds are linked to the correct EESSI libraries. This means that the program can run even without the EESSI environment loaded.

To load the `buildenv` module, run:

```bash
module load buildenv/default-foss-2023b
```

Now you can run `cmake` and `make` to compile CUDA programs using EESSI's modules loaded by `buildenv`.

Additional modules may need to be loaded to compile programs. To see available modules to load in EESSI run:

```bash
module avail
```

#### Useful EESSI Commands

To see modules currently loaded in EESSI, run:

```bash
module list
```

To unload all currently loaded modules:

```bash
module purge
```

To unload a specific module, run (e.g GCC/12.3.0):

```bash
module unload GCC/12.3.0
```

#### Test: Compile deviceQuery from CUDA-Samples

To test that your EESSI setup can compile CUDA, try compiling `deviceQuery` from CUDA-Samples with the following steps:

```bash
git clone https://github.com/NVIDIA/cuda-samples.git
cd cuda-samples/Samples/1_Utilities/deviceQuery
mkdir -p build
cd build
cmake ..
make
./deviceQuery
```

## EESSI Proxy Configuration

EESSI recommend that clusters use a proxy to reduce latency for clients and
avoid excessive load on the EESSI Stratum 1 servers. Squid can be deployed and
configured appropriately as this proxy on separate node(s) using
the OpenTofu variable `additional_nodegroups`, e.g.:

```hcl
additional_nodegroups = {
    # EESSI squid proxy
    squid = {
      nodes = ["squid-0"]
      flavor = squid.flavor
    }
  }
```

EESSI [recommend](https://www.eessi.io/docs/tutorial/access/proxy/#general-recommendations)
that:
> The proxy server should have a 10Gbit link to the client systems, a
sufficiently powerful CPU, a decent amount of memory for the kernel cache (tens
of GBs), and fast local storage (SSD or NVMe).
>
> As a rule of thumb, it is recommended to have (at least) one proxy server for
every couple of hundred worker nodes (100-500).

Generally, both the `squid` nodes and the `eeesi` client nodes can be
appropriately configured simply by setting the squid mode to `eessi`:

  ```yaml
  # environments/site/inventory/group_vars/all/squid.yml:
  squid_conf_mode: eessi
  ```

In this mode, by default:
- `squid` is configured to allow clients from the access network's CIDR, using
  the EESSI-recommended cache configuration
- `eessi` is configured to use the `squid` node IPs on the access network (the
  first network in `cluster_networks`) as proxies.

If this is not suitable then override the defaults provided by `environments/common/inventory/group_vars/all/eessi.yml`
and the `eeesi` and `squid` roles.
