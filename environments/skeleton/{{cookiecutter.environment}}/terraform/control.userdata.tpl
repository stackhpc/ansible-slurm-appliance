#cloud-config
disk_setup:
  /dev/vdb:
    table_type: gpt
    layout: true
fs_setup:
  - label: control_state
    filesystem: ext4
    device: /dev/vdb
    partition: auto
mounts:
  - [LABEL=control_state, ${state_dir}]
