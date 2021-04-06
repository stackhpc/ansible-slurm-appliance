[all:vars]
ansible_user=centos
openhpc_cluster_name=${cluster_name}

[${cluster_name}_login]
${login.name} ansible_host=${login.network[0].fixed_ip_v4} server_networks='${jsonencode({for net in login.network: net.name => [ net.fixed_ip_v4 ] })}'

[${cluster_name}_compute]
%{ for compute in computes ~}
${compute.name} ansible_host=${compute.network[0].fixed_ip_v4} server_networks='${jsonencode({for net in compute.network: net.name => [ net.fixed_ip_v4 ] })}'
%{ endfor ~}

[cluster_login:children]
${cluster_name}_login

[cluster_compute:children]
${cluster_name}_compute

[login:children]
cluster_login

[compute:children]
cluster_compute

[cluster:children]
login
compute