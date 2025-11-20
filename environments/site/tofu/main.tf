terraform {
  required_version = ">= 1.7" # templatestring() function
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~>3.4.0"
    }
  }
}
