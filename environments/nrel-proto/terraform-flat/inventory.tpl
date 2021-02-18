[all:vars]
ansible_user=centos
openhpc_cluster_name=${cluster_name}

[control]
${control.name} ansible_host=${control.network[0].fixed_ip_v4} server_networks='${jsonencode({for net in control.network: net.name => [ net.fixed_ip_v4 ] })}'

[login]
${login.name} ansible_host=${login.network[0].fixed_ip_v4} server_networks='${jsonencode({for net in login.network: net.name => [ net.fixed_ip_v4 ] })}'

[compute]
%{ for compute in computes ~}
${compute.name} ansible_host=${compute.network[0].fixed_ip_v4} server_networks='${jsonencode({for net in compute.network: net.name => [ net.fixed_ip_v4 ] })}'
%{ endfor ~}
