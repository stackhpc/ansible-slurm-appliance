This uses a podman container to build Slurm, which is then copied out of the container into a version directory.

The following arguments to `./configure` are important:
- `--prefix` must match the path the binaries appear to be at (i.e. from the NFS client side). This is because:
    - The `slurm{ctld,d,dbd}` executables hardcode an RPATH, even when passing the `--without-rpath` flag to ./configure.
      This means unless the path they are executed at matches the build prefix, they can't find `libslurmfull.so` on startup, 
      even with entries in `/etc/ld.so.conf.d/`.
    - `PluginDir` defaults to being based on the build prefix. Although it can be overriden in `slurm.conf`, the `slurmd`s do not appear to get this parameter when running configless, so they won't start saying the (default) plugin dir doesn't exist
- `--sysconfdir` must match the path the `slurm.conf` file is at on the nodes. Otherwise `s*` commands running on nodes *without* `slurmd` (i.e. the control node only, for a standard Slurm appliance configuration) cannot find the configuration file unless the `SLURM_CONF` environment variable set.

Note that a tmpdir is hardcoded to a volume mounted on the lab deploy host, due to its small root filesystem.
