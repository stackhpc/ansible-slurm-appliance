cloud_init_userdata_templates_extra:
  - module: fs_setup
    group: control
    template: |
      - label: state
        filesystem: ext4
        device: /dev/vdb
        partition: auto
      - label: home
        filesystem: ext4
        device: /dev/vdc
        partition: auto
  - module: mounts
    group: control
    template: |
      - [LABEL=state, ${state_dir}]
      - [LABEL=home, /exports/home, auto, "x-systemd.required-by=nfs-server.service,x-systemd.before=nfs-server.service"]
