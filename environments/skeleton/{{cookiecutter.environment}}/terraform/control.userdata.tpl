#cloud-config
disk_setup:
  /dev/vdb:
    table_type: gpt
    layout: true
  /dev/vdc:
    table_type: gpt
    layout: true
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
  - [LABEL=home, /exports/home]
