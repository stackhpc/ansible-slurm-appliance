[all:vars]
ansible_user=centos
ssh_proxy=${login.network[0].fixed_ip_v4}
ansible_ssh_common_args='-o ProxyCommand="ssh centos@${login.network[0].fixed_ip_v4} -W %h:%p"'

[${cluster_name}_login]
${login.name} ansible_host=${login.network[0].fixed_ip_v4} server_networks='${jsonencode({for net in login.network: net.name => [ net.fixed_ip_v4 ] })}'

[${cluster_name}_compute]
%{ for compute in computes ~}
${compute.name} ansible_host=${compute.network[0].fixed_ip_v4} server_networks='${jsonencode({for net in compute.network: net.name => [ net.fixed_ip_v4 ] })}'
%{ endfor ~}

[cluster:children]
${cluster_name}_login
${cluster_name}_compute

[cluster_login:children]
${cluster_name}_login

[cluster_compute:children]
${cluster_name}_compute
