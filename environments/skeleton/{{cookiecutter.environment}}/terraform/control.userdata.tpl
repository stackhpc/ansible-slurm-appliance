cloud_init_userdata_templates_extra:
  - module: fs_setup
    group: control
    template: |
      # fileysystems on volumes for appliances_state_dir state and $HOME
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
      # mounts for appliances_state_dir state and $HOME
        - [LABEL=state, ${state_dir}]
        - [LABEL=home, /exports/home, auto, "x-systemd.required-by=nfs-server.service,x-systemd.before=nfs-server.service"]
