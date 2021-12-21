resource "local_file" "hosts" {
  content  = templatefile("${path.module}/inventory.tpl",
                          {
                            "cluster_name": var.cluster_name
                            "control": openstack_compute_instance_v2.control,
                            "logins": openstack_compute_instance_v2.login,
                            "computes": openstack_compute_instance_v2.compute,
                            "compute_types": var.compute_types,
                            "compute_nodes": var.compute_nodes,
                            "volumes": {
                              "home": data.openstack_blockstorage_volume_v3.home
                              "slurmctld": data.openstack_blockstorage_volume_v3.slurmctld
                            }
                            "slurmctl_rdma_port_ip": data.openstack_networking_port_v2.slurmctl_rdma.all_fixed_ips[0]
                          },
                          )
  filename = "../inventory/hosts"
}

resource "local_file" "partitions" {
    content  = templatefile("${path.module}/partitions.tpl",
                            {
                              "compute_types": var.compute_types,
                              "compute_nodes": var.compute_nodes,
                            },
    )
    filename = "../inventory/group_vars/openhpc/partitions.yml"
}
