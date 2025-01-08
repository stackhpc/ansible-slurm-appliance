resource "local_file" "hosts" {
  content  = templatefile("${path.module}/inventory.tpl",
                          {
                            "cluster_name": var.cluster_name,
                            "cluster_domain_suffix": var.cluster_domain_suffix,
                            "control_instances": openstack_compute_instance_v2.control
                            "login_instances": openstack_compute_instance_v2.login
                            "compute_groups": module.compute
                            "state_dir": var.state_dir
                          },
                          )
  filename = "../inventory/hosts.yml"
}

resource "local_file" "partitions" {
    content  = templatefile("${path.module}/partitions.tpl",
                            {
                              "compute_groups": module.compute,
                            },
    )
    filename = "../inventory/group_vars/all/partitions.yml" # as all/ is created by skeleton
}
