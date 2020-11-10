terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "~> 2.0.0"
    }
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
  required_version = ">= 0.13"
}
