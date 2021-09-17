[all:vars]
ansible_user=centos
openhpc_cluster_name=${cluster_name}
slurmctl_rdma_port_ip=${slurmctl_rdma_port_ip}

[control]
${control.name} instance_id=${control.id} ansible_host=${[for n in control.network: n.fixed_ip_v4 if n.access_network][0]} server_networks='${jsonencode({for net in control.network: net.name => net.fixed_ip_v4 })}'

[control:vars]
volumes=${jsonencode(volumes)}

[login]
%{ for login in logins ~}
${login.name} instance_id=${login.id} ansible_host=${[for n in login.network: n.fixed_ip_v4 if n.access_network][0]} server_networks='${jsonencode({for net in login.network: net.name => net.fixed_ip_v4 })}'
%{ endfor ~}

[compute]
%{ for compute in computes ~}
${compute.name} instance_id=${compute.id} ansible_host=${[for n in compute.network: n.fixed_ip_v4 if n.access_network][0]} server_networks='${jsonencode({for net in compute.network: net.name => net.fixed_ip_v4 })}'
%{ endfor ~}

# Define groups for slurm parititions:
%{~ for type_name, type_descr in compute_types}
%{~ if contains(values(compute_nodes), type_name) }
[${cluster_name}_${type_name}]
    %{~ for node_name, node_type in compute_nodes ~}
    %{~ if node_type == type_name }${cluster_name}-${node_name}%{ endif }
    %{~ endfor ~}
%{ endif ~}
%{ endfor ~}

