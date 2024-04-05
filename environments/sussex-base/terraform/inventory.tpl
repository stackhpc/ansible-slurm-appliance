[all:vars]
openhpc_cluster_name=${cluster_name}
cluster_domain_suffix=${cluster_domain_suffix}
ansible_ssh_common_args='-J rocky@${login_fip}'

[control]
%{ for control in control_instances ~}
${ control.name } ansible_host=${[for n in control.network: n.fixed_ip_v4 if n.access_network][0]} node_fqdn=${ control.name }.${cluster_name}.${cluster_domain_suffix} instance_id=${ control.id }
%{ endfor ~}

[login]
%{ for login in login_instances ~}
${ login.name } ansible_host=${[for n in login.network: n.fixed_ip_v4 if n.access_network][0]} node_fqdn=${ login.name }.${cluster_name}.${cluster_domain_suffix} instance_id=${ login.id }
%{ endfor ~}

[compute]
%{ for compute in compute_instances ~}
${ compute.name } ansible_host=${[for n in compute.network: n.fixed_ip_v4 if n.access_network][0]} node_fqdn=${ compute.name }.${cluster_name}.${cluster_domain_suffix}  instance_id=${ compute.id }
%{ endfor ~}
