[all:vars]
ansible_user=centos
openhpc_cluster_name=${cluster_name}

[control]
${control.name}

[login]
%{ for login in logins ~}
${login.name}
%{ endfor ~}

[compute]
%{ for compute in computes ~}
${compute.name}
%{ endfor ~}

# Define groups for slurm parititions:
%{~ for type_name, type_descr in compute_types}
[${cluster_name}_${type_name}]
    %{~ for node_name, node_type in compute_nodes ~}
    %{~ if node_type == type_name }${cluster_name}-${node_name}%{ endif }
    %{~ endfor ~}
%{ endfor ~}
