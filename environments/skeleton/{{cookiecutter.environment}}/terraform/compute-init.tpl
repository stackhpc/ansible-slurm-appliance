#cloud-config
mounts:
  - ["${ control_address }:/home", "/home", "nfs", "defaults", "0", "0"]

write_files:
  - path: /etc/sysconfig/slurmd
    encoding: text/plain
    permissions: "0644"
    owner: root:root
    content: SLURMD_OPTIONS='--conf-server ${ control_address }'
  - path: /etc/openstack/clouds.yaml
    encoding: text/plain
    permissions: "0400"
    owner: root:root
    content: |
      ${ indent(6, clouds_yaml) }
  # have to do this last as munge user doesn't exist on initial deploy which fails this `write_files` module
  - path: /etc/munge/munge.key
    encoding: base64
    permissions: "0400"
    owner: munge:munge
    content: ${ munge_key }
