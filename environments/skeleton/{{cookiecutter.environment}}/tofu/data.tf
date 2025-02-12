data "external" "inventory_secrets" {
  program = ["${path.module}/read-inventory-secrets.py"]

  query = {
    path = var.inventory_secrets_path == "" ? "${path.module}/../inventory/group_vars/all/secrets.yml" : var.inventory_secrets_path
  }
}

data "external" "baremetal_nodes" {
  # returns an empty map if cannot list baremetal nodes
  program = ["bash", "-c", <<-EOT
    openstack baremetal node list --limit 0 -f json 2>/dev/null | \
    jq -r 'try map( { (.Name|tostring): .UUID } ) | add catch {}' || echo '{}'
  EOT
  ]
}
