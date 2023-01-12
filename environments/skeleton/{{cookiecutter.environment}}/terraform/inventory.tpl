[all:vars]
openhpc_cluster_name=${cluster_name}

[control]
${control.name} ansible_host=${control.all_fixed_ips[0]}

[control:vars]
# NB needs to be set on group not host otherwise it is ignored in packer build!
appliances_state_dir=${state_dir}

[login]
%{ for login in logins ~}
${login.name} ansible_host=${login.all_fixed_ips[0]}
%{ endfor ~}

[compute]
%{ for compute in computes ~}
${compute.name} ansible_host=${compute.all_fixed_ips[0]}
%{ endfor ~}

# Define groups for slurm parititions:
%{~ for type_name, type_descr in compute_types}
[${cluster_name}_${type_name}]
    %{~ for node_name, node_type in compute_nodes ~}
        %{~ if node_type == type_name ~}
${cluster_name}-${node_name}
        %{~ endif ~}
%{~ endfor ~}
%{ endfor ~}
