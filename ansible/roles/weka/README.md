# WEKA

This role installs the [WEKA](https://www.weka.io/) client and mounts the filesystem.

It uses the stateless client mode. Please see [WEKA documentation](https://docs.weka.io/weka-filesystems-and-object-stores/mounting-filesystems)
for more information.

It will create `/etc/fstab` entries for the desired mounts and live-mount them.

## Role Variables

### Global variables

- `weka_cgroups_mode`: Option str (default `"force_v2"`). Which cgroup implementation to use.
  This is a global parameter per client host. Using `force_v2` will make systemd isolate weka dedicated CPUs in weka cgroup.
  This applies to `lstopo` and Slurm, causing issues with GPU autodetection because it causes an inconsistency between the
  NVML-reported affinity and Slurm daemon view (the weka-dedicated CPUs don't show up in `hwloc`/`lstopo`).
  In this case, either set `weka_cgroups_mode:"none"` or disable GPU autodetection (see
  [gres_autodetect](https://github.com/stackhpc/ansible-role-openhpc#slurmconf) and `gres` documentation).

### WEKA filesystem mounts

WEKA mounts are described in the `weka_mounts` variable.

- `weka_mounts`: Optional array (default `[]`). list of WEKA filesystem mounts.

It is a dict with following keys, all optional:

- `mount_point`: str. mount point on client host, eg `"/mnt/scratch"` (default `weka_client_mnt_point`).
  The mount point (directory) will be created if it doesn't exist.
- `servers`: str list. weka server list (default `weka_servers`).
  They are usually specified as IP addresses.
- `export`: str. Chosen WEKA filesystem to mount, eg `"/scratch"` (default `weka_export`).
  Like in NFS, a single WEKA cluster can export multiple filesystems, so we have to select which one to mount.
- `mount_options`: options to pass to the `mount` command (default `weka_client_mnt_options`)
  See available options in [WEKA documentation](https://docs.weka.io/weka-filesystems-and-object-stores/mounting-filesystems#additional-mount-options-using-the-stateless-clients-feature).
  Important ones are `core`, `net`, `traces_capacity_mb`.
  You might also want systemd-related options `x-systemd.requires=weka-agent.service,x-systemd.mount-timeout=240,_netdev`.
  See documentation for the defaults below.
- `mount_state`: mount state, eg. `"mounted"` (default `weka_client_mnt_state`).
  See `ansible.posix.mount` allowed values.
  If the weka container is already running, the filesystem will not be remounted but the fstab still modified.

### Defaults

Defaults can be set for `weka_mounts` options:

- `weka_export`: Optional str. Default for `export` in `weka_mounts`.
  Generally it's specified per mount.
- `weka_servers`: Optional array (default `[]`). Default for `servers` in `weka_mounts`.
- `weka_client_mnt_options`: Optional str (default, concatenation of other options, see below). Default for `mount_options`.
  If a single filesystem is mounted per client, `weka_client_mnt_options` is generally not overridden per mount.
- `weka_client_mnt_point`: Optional str (default `"/mnt"`). Default for `mount_point` in `weka_mounts`.
  Generally it's specified per mount.
- `weka_client_mnt_state`: Optional str (default `"mounted"`). Default for `mount_state`.
  Generally it's kept at the default `"mounted"` value globally.

`weka_client_mnt_options` is defined as a concatenation of relevant options, but feel free to override it directly
if it is more appropriate.

Here are the options:

- `weka_client_traces_capacity_mb`: Optional int (default `512`). Value for the `traces_capacity_mb` mount option.  
  If unspecified, traces will almost fill the disk. 512 is the minimal value. In production, maybe 50GB is more reasonable to be useful in debugging.
- `weka_client_mount_core_options`: Optional str (default `"core=<last vCPU on the system>"`).
  Specify one or more cores to allocate to WEKA, in the format `"core=N,core=M"`.
  This values changes depending on the host hardware. The default works for VMs with infiniband SR-IOV passthrough.
- `weka_client_mount_net_options`: Optional str (default empty).
  The network device to use, eg for first infiniband card: `"net=ib0"`.
- `weka_client_mount_systemd_options`: Optional str (default `"x-systemd.requires=weka-agent.service,x-systemd.mount-timeout={{ weka_client_mount_timeout }},_netdev"`).
  systemd-related options for the mount, and `_netdev` marker.
- `weka_client_mount_timeout`: Optional int (default `240`). Value for the `x-systemd.mount-timeout` mount option.
  Mounting a WEKA filesystem can take a couple minutes.
- `weka_client_mount_extra_options`: Optional str (default empty). For additional options.

## Interactions with Slurm (stackhpc.openhpc role)

Both Slurm and the WEKA client make a very controlled use of CPU resources, so we must
ensure a good configuration to avoid them stepping on each other. Depending on `weka_cgroups_mode`, issues will be `slurmd` failing to start
jobs because their CPU allocation is on a WEKA isolated CPU or suboptimal performance because WEKA and a job are overloading
the same core. Other issues will be slurmd failing on startup due to `CPUSpecList` misconfiguration.

This [WEKA documentation page](https://docs.weka.io/best-practice-guides/weka-and-slurm-integration/avoid-conflicting-cpu-allocations)
is an excellent reference on the subject. Here is a short summary from our experience.

The WEKA client creates one slot per given CPU core (2 hyperthreads if hyperthreading is configured)
and runs a polling loop per slot, which saturates the CPU core. There is an extra slot 0,
that utilises about 25% of one CPU but is not pinned to any.

Slurm should not allocate jobs on these CPUs, so we must them in the `CPUSpecList` key in `node_params` for the nodegroup in `openhpc_nodegroups`.
We usually declare the WEKA cores plus an extra one for _system + slot 0_ use but you must confirm it is the optimal settings for you.

**WARNING**: Ensuring WEKA and Slurm parameters match gets more complex because of hyperthreading. Step-by-step description
is available in [WEKA documentation page](https://docs.weka.io/best-practice-guides/weka-and-slurm-integration/avoid-conflicting-cpu-allocations).

- WEKA mount option `core=` takes a whole core (2 threads) out of the available CPUs
- `slurm.conf` `CPUSpecList=` uses virtual CPU IDs (linear numbers: virtual CPU 0,1 = 1st and 2nd threads on first core)
- `slurmd` convert virtual CPU ID to physical one and expands to other threads on same core
  (on a 2 sockets, 16 core per socket system, virtual CPU 0,1 = CPU#0,CPU#32)

Example: on a 2 socket, 16 core per socket system, we reserve cores 22, 23 for WEKA and core 21 for _system + slot 0_.

- set `core=22,core=23` in `weka_client_mnt_options`
- set `CPUSpecList: '42-47'` in `openhpc_nodegroups`:
  44-47 are virtual CPUs for cores 22,23 taken by weka, 42-43 are for core 21 we reserve for the system
- `slurmd` will convert back to CPU numbers `(21,53), (22,54), (23,55)`.

`lstopo` is installed in `/opt/ohpc/pub/libs/hwloc/bin/lstopo` in the appliance.
