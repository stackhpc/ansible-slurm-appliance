Experiment in booting fat image directly to compute node.

# Approach
- Run terraform: nodes are created
- Run site: slurm.conf etc is created and populated with node memory/cpu etc
- Trigger TF to rebuild the compute nodes (e.g. change their image)
- Slurmd and NFS should come up automatically

# Things to note
- There's some very hacky workaround to populate /etc/hosts on reboot via cloud-init given DNS doesn't work. If
we didn't need that (which means userdata gets changed, which means the rebuild it has to be triggered via TF)
then we could use an "openstack rebuild" and this would (with dev) be controllable from Slurm
- basic_users are not defined, so Slurm isn't actually usable except by rocky
- Munge key is in the userdata
- NFS works b/c it has no secrets required
- OOD desktop won't work on compute nodes as the setup for that isn't in the image

# Overal comments
Without a way to inject secrets (if userdata is not acceptable), probably IAM and filesystems
are a bit stuffed. If we only trust SSH to inject these, then really we need to run ssh from
the controller after a slurm-controlled rebuild (or autoscale). In which case maybe using
Ansible is actually a sensible approach ...
