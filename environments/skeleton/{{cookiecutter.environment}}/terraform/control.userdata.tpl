#cloud-config
fs_setup:
  - label: state
    filesystem: ext4
    device: /dev/vdb
    partition: auto
  - label: home
    filesystem: ext4
    device: /dev/vdc
    partition: auto

mounts:
  - [LABEL=state, ${state_dir}]
  - [LABEL=home, /exports/home, auto, "x-systemd.required-by=nfs-server.service,x-systemd.before=nfs-server.service"]
