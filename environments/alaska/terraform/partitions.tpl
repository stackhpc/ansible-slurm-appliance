openhpc_slurm_partitions:
%{~ for type_name, type_descr in compute_types}
%{~ if contains(values(compute_nodes), type_name) }
- name: ${type_name}
%{ endif ~}
%{ endfor ~}
