cluster_config_manager
=========

cluster_config_manager generates and maintains the passwd/shadow/group files for compute nodes and loads the users from IDM.

You can install using Ansible, this repo is an Ansible Galaxy role.

To setup cluster_config_manager, you must setup the below directory structure.  Paths can be different, you must use commit_etc, output, and templates.  For the template files, use the current passwd, group, shadow files on the compute nodes.
/nopt/nrel/admin/cluster_config_manager/commit_etc/compute
/nopt/nrel/admin/cluster_config_manager/commit_etc/compute/passwd
/nopt/nrel/admin/cluster_config_manager/commit_etc/compute/group
/nopt/nrel/admin/cluster_config_manager/commit_etc/compute/shadow
/nopt/nrel/admin/cluster_config_manager/templates/compute/passwd
/nopt/nrel/admin/cluster_config_manager/templates/compute/group
/nopt/nrel/admin/cluster_config_manager/templates/compute/shadow
/nopt/nrel/admin/cluster_config_manager/output/compute

The base path for cluster_config_manager is set with cluster_config_manager_install_dir.

Role Variables
--------------

Below are the defaults.

cluster_config_manager_install_dir: "/nopt/nrel/admin/cluster_config_manager"
cluster_config_manager_groupname: "vs-users"
cluster_config_manager_group_filter_file: "group_filters/verified_vs_groups"
cluster_config_manager_ldap_server: "ldap://ds1.hpc.nrel.gov"
cluster_config_manager_ldap_username: "uid=ldapreadops,cn=users,cn=accounts,dc=hpc,dc=nrel,dc=gov"
cluster_config_manager_ldap_password: "SECRET_replace_me"
is_compute_node: False