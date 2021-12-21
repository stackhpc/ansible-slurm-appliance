# "timestamp" template function replacement:s
locals { timestamp = formatdate("YYMMDD-hhmm", timestamp())}

# Path pointing to root of repository - set by environment variable PKR_VAR_repo_root
variable "repo_root" {
  type = string
}

# Path pointing to environment directory - set by environment variable PKR_VAR_environment_root
variable "environment_root" {
  type = string
}

# VM disk size - needs to match compute VM image
variable "disk_size" {
  type = string
  default = "20G"
}

# Groups (as well as 'builder') to add packer VM to - controls which image is built
variable "groups" {
  type = list(string)
  default = ["compute"]
}

variable "base_img_url" {
  type = string
  default = "https://download.rockylinux.org/pub/rocky/8.5/images/Rocky-8-GenericCloud-8.5-20211114.2.x86_64.qcow2"
}

variable "base_img_checksum" {
  type = string
  default = "sha256:c23f58f26f73fb9ae92bfb4cf881993c23fdce1bbcfd2881a5831f90373ce0c8"
}

source "qemu" "openhpc-vm" {
  iso_url = var.base_img_url
  iso_checksum = var.base_img_checksum
  disk_image = true # as above is .qcow2 not .iso
  disk_size = var.disk_size
  disk_compression = true
  accelerator      = "kvm" # default, if available
  ssh_username = "centos"
  ssh_timeout = "20m"
  net_device       = "virtio-net" # default
  disk_interface   = "virtio" # default
  qemu_binary      = "/usr/libexec/qemu-kvm" # fixes GLib-WARNING **: 13:48:38.600: gmem.c:489: custom memory allocation vtable not supported
  headless         = true
  output_directory = "${var.environment_root}/images"
  ssh_private_key_file = "~/.ssh/id_rsa"
  qemuargs         = [
    ["-monitor", "unix:qemu-monitor.sock,server,nowait"],
    # NOTE: To uncomment the below, you need: mkfifo /tmp/qemu-serial.in /tmp/qemu-serial.outh
    # ["-serial", "pipe:/tmp/qemu-serial"],
    ["-m", "896M"],
    ["-cdrom", "config-drive.iso"]
    ]
  vm_name          = "ohpc-${var.groups[0]}-${local.timestamp}.qcow2" # image name
}

build {
  sources = ["source.qemu.openhpc-vm"]
  provisioner "ansible" {
    playbook_file = "${var.repo_root}/ansible/site.yml"
    host_alias = "packer"
    groups = concat(["builder"], var.groups)
    keep_inventory_file = true # for debugging
    use_proxy = false # see https://www.packer.io/docs/provisioners/ansible#troubleshooting
    # TODO: use completely separate inventory, which just shares common? This will ensure
    # we don't accidently run anything via delegate_to.
    extra_arguments = ["--limit", "builder", "-i", "./ansible-inventory.sh"]
    # TODO: Support vault password
    #ansible_env_vars = ["ANSIBLE_VAULT_PASSWORD_FILE=/home/stack/.kayobe-vault-pass"]
  }
}
