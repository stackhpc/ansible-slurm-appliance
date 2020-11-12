# "timestamp" template function replacement:s
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "qemu" "openhpc2" {
  iso_url = "https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.2.2004-20200611.2.x86_64.qcow2"
  iso_checksum = "sha256:d8984b9baee57b127abce310def0f4c3c9d5b3cea7ea8451fc4ffcbc9935b640"
  disk_image = true
  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  disk_compression = true
  accelerator      = "kvm" # default, if avaialable
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
  vm_name          = "openhpc2-${local.timestamp}"
}

build {
  sources = ["source.qemu.openhpc2"]

}
