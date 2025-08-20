resource "openstack_compute_servergroup_v2" "control" {
  name     = "staging-control-server-group"
  policies = ["soft-affinity"]
}
