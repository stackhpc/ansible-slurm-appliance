all:
    vars:
        openhpc_cluster_name: ${cluster_name}
        cluster_domain_suffix: ${cluster_domain_suffix}
        login_fip: ${login_fip}
        state_volume_size: ${state_volume.size}

control:
    hosts:
%{ for control in control_instances ~}
        ${ control.name }:
            ansible_host: ${[for n in control.network: n.fixed_ip_v4 if n.access_network][0]}
            instance_id: ${ control.id }
%{ endfor ~}

login:
    hosts:
%{ for login in login_instances ~}
        ${ login.name }:
            ansible_host: ${[for n in login.network: n.fixed_ip_v4 if n.access_network][0]}
            instance_id: ${ login.id }
%{ endfor ~}

squid:
    hosts:
%{ for squid in squid_instances ~}
        ${ squid.name }:
            ansible_host: ${[for n in squid.network: n.fixed_ip_v4 if n.access_network][0]}
            instance_id: ${ squid.id }
%{ endfor ~}

%{ for group_name in keys(compute_groups) ~}
${cluster_name}_${group_name}:
    hosts:
%{ for node in compute_groups[group_name]["compute_instances"] ~}
        ${ node.name }:
            ansible_host: ${node.access_ip_v4}
            instance_id: ${ node.id }
%{ endfor ~}
%{ endfor ~}

compute:
    children:
%{ for group_name in keys(compute_groups) ~}
        ${cluster_name}_${group_name}:
%{ endfor ~}

%{ for inventory_group in distinct(
    flatten([for c in var_compute: lookup(c, "inventory_groups", [])])
    ) ~}
${inventory_group}:
    children:
%{ for k, v in var_compute ~}
%{ if contains(lookup(v, "inventory_groups", []), inventory_group) ~}
        ${cluster_name}_${k}:
%{ endif ~}
%{ endfor ~}
%{ endfor ~}
