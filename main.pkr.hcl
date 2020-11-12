# "timestamp" template function replacement:s
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "qemu" "openhpc2" {
  accelerator      = "kvm"
  boot_command     = ["<tab> console=ttyS0 text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos-8.ks<enter><wait>"]
  boot_wait        = "10s"
  disk_interface   = "virtio"
  disk_size        = "3072M"
  format           = "qcow2"
  headless         = true
  http_directory   = "http"
  iso_checksum     = "sha256:c67876a5602faa17f68b40ccf2628799b87454aa67700f0f57eec15c6ccdd98c"
  iso_url          = "http://mirror.cs.vt.edu/pub/CentOS/8/isos/x86_64/CentOS-8.2.2004-x86_64-boot.iso"
  net_device       = "virtio-net"
  output_directory = "build"
  qemu_binary      = "/usr/libexec/qemu-kvm"
  qemuargs         = [
    ["-monitor", "unix:qemu-monitor.sock,server,nowait"],
    ["-serial", "pipe:/tmp/qemu-serial"], ["-m", "896M"],
    ]
  shutdown_command = "systemctl poweroff"
  ssh_username     = "root"
  ssh_password     = "passwd"
  ssh_timeout      = "10m"
  vm_name          = "centos-8-amd64-${local.timestamp}.qcow2"
}

build {
  sources = ["source.qemu.openhpc2"]

}
