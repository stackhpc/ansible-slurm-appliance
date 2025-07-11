resource "local_file" "hosts" {
  content  = templatefile("${path.module}/inventory.tpl",
                          {
                            "cluster_name": var.cluster_name,
                            "cluster_domain_suffix": var.cluster_domain_suffix
                            "control": openstack_compute_instance_v2.control
                            "control_fqdn": local.control_fqdn
                            "login_groups": module.login
                            "compute_groups": module.compute
                            "baremetal_compute_instances": flatten([for group in keys(module.compute) : keys(module.compute[group]["compute_instances"]) if module.compute[group]["is_baremetal"]])
                            "additional_groups": module.additional
                            "state_dir": var.state_dir
                            "cluster_home_volume": var.home_volume_provisioning != "none"
                          },
                          )
  filename = "../inventory/hosts.yml"
}
