# "timestamp" template function replacement:s
locals { timestamp = formatdate("YYMMDD-hhmm", timestamp())}

source "qemu" "openhpc-compute" {
  iso_url = "https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.2.2004-20200611.2.x86_64.qcow2"
  iso_checksum = "sha256:d8984b9baee57b127abce310def0f4c3c9d5b3cea7ea8451fc4ffcbc9935b640"
  disk_image = true # as above is .qcow2 not .iso
  disk_size = "20G" # needs to match compute VM
  disk_compression = true
  accelerator      = "kvm" # default, if available
  ssh_username = "centos"
  ssh_timeout = "20m"
  net_device       = "virtio-net" # default
  disk_interface   = "virtio" # default
  qemu_binary      = "/usr/libexec/qemu-kvm" # fixes GLib-WARNING **: 13:48:38.600: gmem.c:489: custom memory allocation vtable not supported
  headless         = true
  output_directory = "build"
  ssh_private_key_file = "~/.ssh/id_rsa"
  qemuargs         = [
    ["-monitor", "unix:qemu-monitor.sock,server,nowait"],
    ["-serial", "pipe:/tmp/qemu-serial"], ["-m", "896M"],
    ["-cdrom", "config-drive.iso"]
    ]
  vm_name          = "testohpc-compute.qcow2" # image name
  shutdown_command = "sudo shutdown -P now"
}

build {
  sources = ["source.qemu.openhpc-compute"]
  provisioner "ansible" {
    playbook_file = "slurm-image.yml"
    host_alias = "builder"
    groups = ["cluster", "cluster_compute"]
    keep_inventory_file = true # for debugging
    use_proxy = false # see https://www.packer.io/docs/provisioners/ansible#troubleshooting
  }
}
