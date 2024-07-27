[all:vars]
ansible_user=rocky
openhpc_cluster_name=${cluster_name}
ansible_ssh_common_args='-o ProxyCommand="ssh rocky@${proxy_fip} -W %h:%p"'

[control]
${control.name} ansible_host=${[for n in control.network: n.fixed_ip_v4 if n.access_network][0]} server_networks='${jsonencode({for net in control.network: net.name => [ net.fixed_ip_v4 ] })}'

[admin]
${cluster_name}-devadmin

[login]
%{ for login in logins ~}
${login.name} ansible_host=${[for n in login.network: n.fixed_ip_v4 if n.access_network][0]} server_networks='${jsonencode({for net in login.network: net.name => [ net.fixed_ip_v4 ] })}'
%{ endfor ~}

[compute]
%{ for compute in computes ~}
${compute.name} ansible_host=${[for n in compute.network: n.fixed_ip_v4 if n.access_network][0]} server_networks='${jsonencode({for net in compute.network: net.name => [ net.fixed_ip_v4 ] })}'
%{ endfor ~}

## Define groups for slurm parititions:
#################################################################

[${cluster_name}_t]

[${cluster_name}_sm]

[${cluster_name}_std]

[${cluster_name}_lg]
${cluster_name}-devlg-[001:002]

[${cluster_name}_lg_intel]
${cluster_name}-devlg-intel-001

#################################################################
[a100:children]
${cluster_name}_gpu
${cluster_name}_gpu3

[${cluster_name}_gpu]
${cluster_name}-devgpu-[001:002]

[${cluster_name}_gpu3]
${cluster_name}-devpu3-[001:002]

