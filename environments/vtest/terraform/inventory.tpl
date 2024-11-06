[all:vars]
ansible_user=rocky
openhpc_cluster_name=${cluster_name}
ansible_ssh_common_args='-o ProxyCommand="ssh rocky@${proxy_fip} -W %h:%p"'
ansible_python_interpreter=/usr/bin/python3

[control]
${control.name} ansible_host=${[for n in control.network: n.fixed_ip_v4 if n.access_network][0]} server_networks='${jsonencode({for net in control.network: net.name => [ net.fixed_ip_v4 ] })}'

[admin]
${cluster_name}-vtadmin

[login]
%{ for login in logins ~}
${login.name} ansible_host=${[for n in login.network: n.fixed_ip_v4 if n.access_network][0]} server_networks='${jsonencode({for net in login.network: net.name => [ net.fixed_ip_v4 ] })}'
%{ endfor ~}

[compute]
%{ for compute in computes ~}
${compute.name} ansible_host=${[for n in compute.network: n.fixed_ip_v4 if n.access_network][0]} server_networks='${jsonencode({for net in compute.network: net.name => [ net.fixed_ip_v4 ] })}'
%{ endfor ~}

## Define groups for slurm partitions:
#################################################################
# large nodes

[${cluster_name}_lg:children]
${cluster_name}_amdlg
${cluster_name}_intellg

[${cluster_name}_amdlg]
${cluster_name}-vtlg-[001:003]

[${cluster_name}_intellg]
${cluster_name}-vtlg-[004:006]


################################################################# 
# gpu nodes

[${cluster_name}_gpu:children]
${cluster_name}_gpu0
${cluster_name}_gpu3

# a100-40:1 nodes
[${cluster_name}_gpu0]
${cluster_name}-vtgpu-[001:004]

# the A100-80:8 nodes
[${cluster_name}_gpu3]
${cluster_name}-vtgpu-[005:008]

# A100-40:4 nodes
# [${cluster_name}_gpu5]
# ${cluster_name}-vtgpu-050