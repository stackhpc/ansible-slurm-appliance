terraform {
 required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.2"
    }
  }
}

variable "environment_root" {
  type = string
}

variable "compute_names" {
  default = ["compute-0", "compute-1"]
}

variable "cluster_name" {
  default = "testohpc"
}

locals {
    all_hosts = toset(concat(["${var.cluster_name}-login-0", "${var.cluster_name}-control-0"], [for x in var.compute_names: "${var.cluster_name}-${x}"]))
}

# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "storage-pool" {
  name = var.cluster_name
  type = "dir"
  path = "/tmp/terraform-provider-libvirt-pool-${var.cluster_name}"
}

# Create storage for each machine
resource "libvirt_volume" "login" {
  name   = "login"
  pool   = libvirt_pool.storage-pool.name
  source = "https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.qcow2"
  format = "qcow2"
}

resource "libvirt_volume" "control" {
  name   = "control"
  pool   = libvirt_pool.storage-pool.name
  source = "https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.qcow2"
  format = "qcow2"
}

resource "libvirt_volume" "compute" {
  for_each = toset(var.compute_names)
  name   = each.value
  pool   = libvirt_pool.storage-pool.name
  source = "https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.qcow2"
  format = "qcow2"
}

data "template_file" "user_data" {
  for_each = local.all_hosts
  template = templatefile("${path.module}/cloud_init.cfg", {"hostname": each.value })
}

# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "commoninit" {
  for_each = local.all_hosts
  name           = "${each.value}-commoninit.iso"
  user_data      = data.template_file.user_data[each.value].rendered
  pool           = libvirt_pool.storage-pool.name
}

# Create the machine
resource "libvirt_domain" "login" {
  name   = "${var.cluster_name}-login-0"
  memory = "512"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.commoninit["${var.cluster_name}-login-0"].id

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.login.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  network_interface {
    network_name = "default"

    # Requires qemu-agent container if network is not native to libvirt
    wait_for_lease = true
  }
}

resource "libvirt_domain" "control" {
  name   = "${var.cluster_name}-control-0"
  memory = "4096"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.commoninit["${var.cluster_name}-control-0"].id

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.control.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  network_interface {
    network_name = "default"

    # Requires qemu-agent container if network is not native to libvirt
    wait_for_lease = true
  }
}

resource "libvirt_domain" "compute" {
  for_each = toset(var.compute_names)
  name   = "${var.cluster_name}-${each.value}"
  memory = "512"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.commoninit["${var.cluster_name}-${each.value}"].id

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.compute[each.value].id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  network_interface {
    network_name = "default"

    # Requires qemu-agent container if network is not native to libvirt
    wait_for_lease = true
  }
}


resource "local_file" "hosts" {
  content  = templatefile("${path.module}/inventory.tpl",
                          {
                            "cluster_name": var.cluster_name
                            "login": libvirt_domain.login,
                            "control": libvirt_domain.control,
                            "computes": libvirt_domain.compute,
                          },
                          )
  filename = "${var.environment_root}/inventory/hosts"
}