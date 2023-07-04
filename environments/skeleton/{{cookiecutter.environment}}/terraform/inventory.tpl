[all:vars]
openhpc_cluster_name=${cluster_name}
cluster_domain_suffix=${cluster_domain_suffix}

[control]
%{ for control in control_instances ~}
${ control.name } ansible_host=${[for n in control.network: n.fixed_ip_v4 if n.access_network][0]} node_fqdn=${ control.name }.${cluster_name}.${cluster_domain_suffix}
%{ endfor ~}

[control:vars]
# NB needs to be set on group not host otherwise it is ignored in packer build!
appliances_state_dir=${state_dir}

[login]
%{ for login in login_instances ~}
${ login.name } ansible_host=${[for n in login.network: n.fixed_ip_v4 if n.access_network][0]} node_fqdn=${ login.name }.${cluster_name}.${cluster_domain_suffix}
%{ endfor ~}

[compute]
%{ for compute in compute_instances ~}
${ compute.name } ansible_host=${[for n in compute.network: n.fixed_ip_v4 if n.access_network][0]} node_fqdn=${ compute.name }.${cluster_name}.${cluster_domain_suffix}
%{ endfor ~}

# Define groups for slurm parititions:
%{~ for type_name, type_descr in compute_types}
[${cluster_name}_${type_name}]
    %{~ for node_name, node_type in compute_nodes ~}
        %{~ if node_type == type_name ~}
${ compute_instances[node_name].name }
        %{~ endif ~}
%{~ endfor ~}
%{ endfor ~}
