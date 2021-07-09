resource "local_file" "hosts" {
  content  = templatefile("${path.module}/inventory.tpl",
                          {
                            "cluster_name": var.cluster_name
                            "control": openstack_compute_instance_v2.control,
                            "logins": openstack_compute_instance_v2.login,
                            "computes": openstack_compute_instance_v2.compute,
                            "compute_types": var.compute_types,
                            "compute_nodes": var.compute_nodes,
                          },
                          )
  filename = "../inventory/hosts"
}

locals {
  openhpc_slurm_partitions = {
    openhpc_slurm_partitions: [for name, _ in var.compute_types : {"name": name}]
  }
}

resource "local_file" "slurm_partitions" {
  content  = yamlencode(local.openhpc_slurm_partitions)
  filename = "../inventory/group_vars/openhpc/partitions.yml"
}