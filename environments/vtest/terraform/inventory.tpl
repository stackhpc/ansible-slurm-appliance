[all:vars]
ansible_user=rocky
openhpc_cluster_name=${cluster_name}
ansible_ssh_common_args='-o ProxyCommand="ssh rocky@${proxy_fip} -W %h:%p"'

[control]
${control.name} ansible_host=${[for n in control.network: n.fixed_ip_v4 if n.access_network][0]} server_networks='${jsonencode({for net in control.network: net.name => [ net.fixed_ip_v4 ] })}'

[admin]
${cluster_name}-vt-admin

[login]
%{ for login in logins ~}
${login.name} ansible_host=${[for n in login.network: n.fixed_ip_v4 if n.access_network][0]} server_networks='${jsonencode({for net in login.network: net.name => [ net.fixed_ip_v4 ] })}'
%{ endfor ~}

[compute]
%{ for compute in computes ~}
${compute.name} ansible_host=${[for n in compute.network: n.fixed_ip_v4 if n.access_network][0]} server_networks='${jsonencode({for net in compute.network: net.name => [ net.fixed_ip_v4 ] })}'
%{ endfor ~}

## Define groups for slurm parititions:
[${cluster_name}_lg]
${cluster_name}-vt-lg-001
${cluster_name}-vt-lg-002

[${cluster_name}_sm]
${cluster_name}-vt-sm-001
${cluster_name}-vt-sm-002

[${cluster_name}_gpu]
${cluster_name}-vt-gpu-001


# vt-lg-001: "large"
# vt-lg-002: "large"
# vt-sm-001: "small"
# vt-sm-002: "small"
# vt-gpu-001: "gpu"
