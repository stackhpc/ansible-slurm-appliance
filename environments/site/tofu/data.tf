data "external" "baremetal_nodes" {
  # returns an empty map if cannot list baremetal nodes
  program = ["${path.module}/baremetal-node-list.py"]
  query = {}
}
