#cloud-config
mounts:
  - ["${ control_address }:/home", "/home", "nfs", "defaults", "0", "0"]

write_files:  
  - path: /etc/munge/munge.key
    encoding: base64
    permissions: "0400"
    owner: munge:munge
    content: ${munge_key}
  
  - path: /etc/sysconfig/slurmd
    encoding: text/plain
    permissions: "0644"
    owner: root:root
    content: SLURMD_OPTIONS='--conf-server ${ control_address }'
  


