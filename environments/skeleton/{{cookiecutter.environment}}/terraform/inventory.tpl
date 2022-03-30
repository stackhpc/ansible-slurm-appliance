[all:vars]
ansible_user=centos
ssh_proxy=${login.network[0].fixed_ip_v4}
openhpc_cluster_name=${cluster_name}

[${cluster_name}_login]
${login.name} ansible_host=${login.network[0].fixed_ip_v4} networks='${jsonencode({for net in login.network: net.name => [ net.fixed_ip_v4 ] })}'

[${cluster_name}_compute]
%{ for compute in computes ~}
${compute.name} ansible_host=${compute.network[0].fixed_ip_v4} networks='${jsonencode({for net in compute.network: net.name => [ net.fixed_ip_v4 ] })}'
%{ endfor ~}

[${cluster_name}_compute:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh centos@${login.network[0].fixed_ip_v4} -W %h:%p"'

[login:children]
${cluster_name}_login

[compute:children]
${cluster_name}_compute

[cluster:children]
login
compute
