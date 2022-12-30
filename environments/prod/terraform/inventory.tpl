[all:vars]
ansible_user=rocky
openhpc_cluster_name=${cluster_slurm_name}
ansible_ssh_common_args='-o ProxyCommand="ssh rocky@${proxy_fip} -W %h:%p"'

[control]
${control.name} ansible_host=${[for n in control.network: n.fixed_ip_v4 if n.access_network][0]} server_networks='${jsonencode({for net in control.network: net.name => [ net.fixed_ip_v4 ] })}'

[login]
%{ for login in logins ~}
${login.name} ansible_host=${[for n in login.network: n.fixed_ip_v4 if n.access_network][0]} server_networks='${jsonencode({for net in login.network: net.name => [ net.fixed_ip_v4 ] })}'
%{ endfor ~}

[admin]
${cluster_name}-admin

[compute]
%{ for compute in computes ~}
${compute.name} ansible_host=${[for n in compute.network: n.fixed_ip_v4 if n.access_network][0]} server_networks='${jsonencode({for net in compute.network: net.name => [ net.fixed_ip_v4 ] })}'
%{ endfor ~}

## Define groups for slurm parititions:
[${cluster_slurm_name}_lg]
${cluster_name}-lg-[0001:0031]

[${cluster_slurm_name}_std]
${cluster_name}-std-[0001:0060]

[${cluster_slurm_name}_sm]
${cluster_name}-sm-[0001:0028]

[${cluster_slurm_name}_t]
${cluster_name}-t-[0001:0015]

[${cluster_slurm_name}_gpu]
${cluster_name}-gpu-[0001:0016]
