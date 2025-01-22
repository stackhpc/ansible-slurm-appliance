all:
    vars:
        openhpc_cluster_name: ${cluster_name}
        cluster_domain_suffix: ${cluster_domain_suffix}

control:
    hosts:
%{ for control in control_instances ~}
        ${ control.name }:
            ansible_host: ${[for n in control.network: n.fixed_ip_v4 if n.access_network][0]}
            instance_id: ${ control.id }
            networks: ${jsonencode({for n in control.network: n.name => {"fixed_ip_v4": n.fixed_ip_v4, "fixed_ip_v6": n.fixed_ip_v6}})}
%{ endfor ~}
    vars:
        appliances_state_dir: ${state_dir} # NB needs to be set on group not host otherwise it is ignored in packer build!


%{ for group_name in keys(login_groups) ~}
${cluster_name}_${group_name}:
    hosts:
%{ for node in login_groups[group_name]["compute_instances"] ~}
        ${ node.name }:
            ansible_host: ${node.access_ip_v4}
            instance_id: ${ node.id }
            image_id: ${ node.image_id }
            networks: ${jsonencode({for n in node.network: n.name => {"fixed_ip_v4": n.fixed_ip_v4, "fixed_ip_v6": n.fixed_ip_v6}})}
%{ endfor ~}
%{ endfor ~}

login:
    children:
%{ for group_name in keys(login_groups) ~}
        ${cluster_name}_${group_name}:
%{ endfor ~}

%{ for group_name in keys(compute_groups) ~}
${cluster_name}_${group_name}:
    hosts:
%{ for node in compute_groups[group_name]["compute_instances"] ~}
        ${ node.name }:
            ansible_host: ${node.access_ip_v4}
            instance_id: ${ node.id }
            image_id: ${ node.image_id }
            networks: ${jsonencode({for n in node.network: n.name => {"fixed_ip_v4": n.fixed_ip_v4, "fixed_ip_v6": n.fixed_ip_v6}})}
%{ endfor ~}
%{ endfor ~}

compute:
    children:
%{ for group_name in keys(compute_groups) ~}
        ${cluster_name}_${group_name}:
%{ endfor ~}
