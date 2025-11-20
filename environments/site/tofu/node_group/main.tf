terraform {
  required_version = ">= 0.14"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~>3.4.0"
    }
  }
}
