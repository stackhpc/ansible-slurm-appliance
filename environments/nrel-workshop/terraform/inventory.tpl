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
%{ for type_name, type_descr in compute_types ~}
[${cluster_name}_${type_name}]
    %{ for node_name, node_type in compute_nodes ~}
%{ if node_type == type_name }${cluster_name}-${node_name}%{ endif }
    %{ endfor ~}
%{ endfor ~}
