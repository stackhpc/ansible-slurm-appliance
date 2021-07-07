[all:vars]
ansible_user=centos
openhpc_cluster_name=${cluster_name}

[control]
${control.name} ansible_host=${[for n in control.network: n.fixed_ip_v4 if n.access_network][0]} server_networks='${jsonencode({for net in control.network: net.name => [ net.fixed_ip_v4 ] })}'

[login]
%{ for login in logins ~}
${login.name} ansible_host=${[for n in login.network: n.fixed_ip_v4 if n.access_network][0]} server_networks='${jsonencode({for net in login.network: net.name => [ net.fixed_ip_v4 ] })}'
%{ endfor ~}

[compute]
%{ for compute in computes ~}
${compute.name} ansible_host=${[for n in compute.network: n.fixed_ip_v4 if n.access_network][0]} server_networks='${jsonencode({for net in compute.network: net.name => [ net.fixed_ip_v4 ] })}'
%{ endfor ~}

# Define groups for slurm parititions:
%{ for compute_type in compute_types ~}
[${cluster_name}_${compute_type}]
    %{ for nodename, nodetype in compute_nodes ~}
%{ if nodetype == compute_type }${cluster_name}-${nodename}%{ endif }
    %{ endfor ~}
%{ endfor ~}
