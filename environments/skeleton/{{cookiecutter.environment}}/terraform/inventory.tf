resource "local_file" "hosts" {
  content  = templatefile("${path.module}/inventory.tpl",
                          {
                            "cluster_name": var.cluster_name,
                            "control": openstack_networking_port_v2.control,
                            "state_dir": var.state_dir,
                            "logins": openstack_networking_port_v2.login,
                            "computes": openstack_networking_port_v2.compute,
                            "compute_types": var.compute_types,
                            "compute_nodes": var.compute_nodes,
                            "subnet": data.openstack_networking_subnet_v2.cluster_subnet,
                          },
                          )
  filename = "../inventory/hosts"
}

resource "local_file" "partitions" {
    content  = templatefile("${path.module}/partitions.tpl",
                            {
                              "compute_types": var.compute_types,
                            },
    )
    filename = "../inventory/group_vars/all/partitions.yml" # as all/ is created by skeleton
}
