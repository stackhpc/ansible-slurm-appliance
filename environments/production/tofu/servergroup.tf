resource "openstack_compute_servergroup_v2" "control" {
  name     = "production-control-server-group"
  policies = ["soft-affinity"]
}
