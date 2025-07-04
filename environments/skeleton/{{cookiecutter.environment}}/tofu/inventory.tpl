all:
    vars:
        openhpc_cluster_name: ${cluster_name}
        cluster_domain_suffix: ${cluster_domain_suffix}
        cluster_home_volume: ${cluster_home_volume}
        cluster_compute_groups: ${jsonencode(keys(compute_groups))}

control:
    hosts:
        ${ control.name }:
            ansible_host: ${control.access_ip_v4}
            instance_id: ${control.id}
            networks: ${jsonencode({for n in control.network: n.name => {"fixed_ip_v4": n.fixed_ip_v4, "fixed_ip_v6": n.fixed_ip_v6}})}
            node_fqdn: ${control_fqdn}
    vars:
        appliances_state_dir: ${state_dir} # NB needs to be set on group not host otherwise it is ignored in packer build!

# --- login nodes ---
%{ for group_name in keys(login_groups) ~}
${cluster_name}_${group_name}:
    hosts:
%{ for nodename, node in login_groups[group_name]["compute_instances"] ~}
        ${ node.name }:
            ansible_host: ${node.access_ip_v4}
            instance_id: ${ node.id }
            image_id: ${ node.image_id }
            networks: ${jsonencode({for n in node.network: n.name => {"fixed_ip_v4": n.fixed_ip_v4, "fixed_ip_v6": n.fixed_ip_v6}})}
            node_fqdn: ${login_groups[group_name]["fqdns"][nodename]}
%{ endfor ~}
%{ endfor ~}

login:
    children:
%{ for group_name in keys(login_groups) ~}
        ${cluster_name}_${group_name}:
%{ endfor ~}

# --- compute nodes ---
%{ for group_name in keys(compute_groups) ~}
${cluster_name}_${group_name}:
    hosts:
%{ for nodename, node in compute_groups[group_name]["compute_instances"] ~}
        ${ node.name }:
            ansible_host: ${node.access_ip_v4}
            instance_id: ${ node.id }
            networks: ${jsonencode({for n in node.network: n.name => {"fixed_ip_v4": n.fixed_ip_v4, "fixed_ip_v6": n.fixed_ip_v6}})}
            node_fqdn: ${compute_groups[group_name]["fqdns"][nodename]}
%{ endfor ~}
    vars:
        # NB: this is the target image, not necessarily what is provisioned
        image_id: ${compute_groups[group_name]["image_id"]}

${group_name}:
    children:
        ${cluster_name}_${group_name}:

%{ endfor ~}

compute:
    children:
%{ for group_name in keys(compute_groups) ~}
        ${cluster_name}_${group_name}:
%{ endfor ~}

# --- additional nodes ---
%{ for group_name in keys(additional_groups) ~}
${cluster_name}_${group_name}:
    hosts:
%{ for nodename, node in additional_groups[group_name]["compute_instances"] ~}
        ${ node.name }:
            ansible_host: ${node.access_ip_v4}
            instance_id: ${ node.id }
            networks: ${jsonencode({for n in node.network: n.name => {"fixed_ip_v4": n.fixed_ip_v4, "fixed_ip_v6": n.fixed_ip_v6}})}
            node_fqdn: ${additional_groups[group_name]["fqdns"][nodename]}
%{ endfor ~}
${group_name}:
    children:
        ${cluster_name}_${group_name}:

%{ endfor ~}
additional:
    children:
%{ for group_name in keys(additional_groups) ~}
        ${cluster_name}_${group_name}:
%{ endfor ~}
