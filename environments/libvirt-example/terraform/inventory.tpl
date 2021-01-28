[all:vars]
ansible_user=centos
ansible_password=terraform-libvirt-linux
openhpc_cluster_name=${cluster_name}
host_key_checking=False

[${cluster_name}_login]
${login.name} ansible_host=${login.network_interface.0.addresses.0}

[${cluster_name}_control]
${control.name} ansible_host=${control.network_interface.0.addresses.0}

[${cluster_name}_compute]
%{ for compute in computes ~}
${compute.name} ansible_host=${compute.network_interface.0.addresses.0}
%{ endfor ~}

[login:children]
${cluster_name}_login

[control:children]
${cluster_name}_control

[computes:children]
${cluster_name}_compute

[cluster:children]
login
control
computes
