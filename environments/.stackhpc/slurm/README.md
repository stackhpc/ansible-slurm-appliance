This uses a podman container to build Slurm, which is then copied out of the container into `build/23.02.5/`.
The `build/`  directory is NFS-exported to the cluster as `/slurm`, so nodes see `/slurm/23.02.5`.

There are some niggles worth noting:
- The prefix Slurm is built at in the container must match the path the nodes see it at (i.e. from the NFS client side). This
  is because:
    - The `slurm{ctld,d,dbd}` executables hardcode an RPATH, even when passing the `--without-rpath` flag to ./configure.
      This means unless the path they are executed at matches the build prefix, they can't find `libslurmfull.so` on startup, 
      even with entries in `/etc/ld.so.conf.d/`.
    - `PluginDir` defaults to being based on the build prefix. Although it can be overriden in `slurm.conf`, the `slurmd`s do not appear to get this parameter when running configless, so they won't start saying the (default) plugin dir doesn't exist
- `--sysconfdir` is specifically set to `/etc/slurm`, as otherwise it is based on the build prefix.


Assuming `podman` is installed, running the following in this directory will build Slurm and copy it out to the host. As the host's root disk was small, the below includes some TMPDIR/tmpdir options to try to place temporary build artifacts on a larger attached volume. However, ~10GB free was still required on the root disk to complete the build.

    $ export TMPDIR=/mnt/image-storage/tmp # some large persistent storage
    $ mkdir -p build/23.02.5/
    $ rm -rf build/23.02.5/*
    $ podman --tmpdir=/mnt/image-storage/tmp build \
        --build-arg SLURM_PREFIX=/slurm/23.02.5/ \
        . -t slurm-23.02.5 \
        --output build/23.02.5/


As a convenience, the output of "./configure --help" is included as `configure.help`.
