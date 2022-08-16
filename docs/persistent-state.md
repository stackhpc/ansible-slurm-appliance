# Configuration of Persistent State

To enable cluster state to persist beyond individual node lifetimes (e.g. to survive a cluster deletion or rebuild) set `appliances_state_dir` to the path of a directory on persistent storage.

At present this will affect the following items:
- `slurmctld` state, i.e. the Slurm queue.
- The MySQL database for `slurmdbd`, i.e. Slurm accounting information as shown by the `sacct` command.
- Prometheus database
- Grafana data

If using the `environments/common/layout/everything` Ansible groups template (which is the default for a new cookiecutter-produced enviromnent) then these services will all be on the `control` node and hence only this node requires persistent storage.

Note that if `appliances_state_dir` is defined, the path it gives must exist and should be owned by root. Directories will be created within this with appropriate permissions for each item of state defined above.

A new cookiecutter-produced environment supports persistent state in the default Terraform (see `environments/skeleton/{{cookiecutter.environment}}/terraform/`) by:

- Defining a volume with a default size of 150GB - this can be controlled by the Terraform variable `state_volume_size`.
- Attaching it to the control node.
- Defining cloud-init userdata for the control node which partitions, formats and mounts this volume to `/var/lib/state`.
- Defining `appliances_state_dir` for the control node in the (Terraform-templated) the `inventory/hosts` file.

**NB: The default Terraform is provided as a working example and for internal CI use - therefore this volume is deleted when running `terraform destroy` - this is probably not suitable for
a production environment.**

In general, the Prometheus data is likely to be the only sizeable state stored. The size of this can be influenced through [Prometheus role variables](https://github.com/cloudalchemy/ansible-prometheus#role-variables), e.g.:
- `prometheus_storage_retention` - [default](../environments/common/inventory/group_vars/all/prometheus.yml) 31d
- `prometheus_storage_retention_size` - [default](../environments/common/inventory/group_vars/all/prometheus.yml) 100GB
- `prometheus_global.scrape_interval` and `scrape_interval` for [specific scrape definitions](../environments/common/inventory/group_vars/all/prometheus.yml)
