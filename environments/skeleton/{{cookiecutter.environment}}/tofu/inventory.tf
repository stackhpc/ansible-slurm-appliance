resource "local_file" "hosts" {
  content  = templatefile("${path.module}/inventory.tpl",
                          {
                            "cluster_name": var.cluster_name,
                            "cluster_domain_suffix": var.cluster_domain_suffix,
                            "control": openstack_compute_instance_v2.control
                            "login_groups": module.login
                            "compute_groups": module.compute
                            "state_dir": var.state_dir
                            "cluster_home_volume": var.home_volume_provisioning != "none"
                          },
                          )
  filename = "../inventory/hosts.yml"
}
