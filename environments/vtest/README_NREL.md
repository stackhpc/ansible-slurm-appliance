#Run this:

    ansible-galaxy install --force --roles-path ./roles -r requirements_local_env.yml

exit 0

################################################################# 

```
openstack port create --network external vtest-compile-port0
10.60.124.69  This is sticky
# In DNS: # vtest-compile = 10.60.124.69
```

```
openstack server create --os-compute-api-version 2.90  --image aco-rocky9.4-final \
--flavor vermilion_util_c8m15 --key-name vsdeployer  --port vtest-compile-port0  \
--description "vtest -- compile slurm here for test deploy"  \
vtest-slurm-build
```

```
$ openstack port create --network external vtest-compile-port0
+-------------------------+----------------------------------------------------------------------------------------------------+
| Field                   | Value                                                                                              |
+-------------------------+----------------------------------------------------------------------------------------------------+
| admin_state_up          | UP                                                                                                 |
| allowed_address_pairs   |                                                                                                    |
| binding_host_id         |                                                                                                    |
| binding_profile         |                                                                                                    |
| binding_vif_details     |                                                                                                    |
| binding_vif_type        | unbound                                                                                            |
| binding_vnic_type       | normal                                                                                             |
| created_at              | 2024-10-24T20:18:23Z                                                                               |
| data_plane_status       | None                                                                                               |
| description             |                                                                                                    |
| device_id               |                                                                                                    |
| device_owner            |                                                                                                    |
| device_profile          | None                                                                                               |
| dns_assignment          | fqdn='host-10-60-124-69.vs.hpc.nrel.gov.', hostname='host-10-60-124-69', ip_address='10.60.124.69' |
| dns_domain              |                                                                                                    |
| dns_name                |                                                                                                    |
| extra_dhcp_opts         |                                                                                                    |
| fixed_ips               | ip_address='10.60.124.69', subnet_id='039f7271-3529-4c95-86ff-ca476ffef8e5'                        |
| hardware_offload_type   | None                                                                                               |
| hints                   |                                                                                                    |
| id                      | 0332ba84-d669-4434-af18-7633d41071f9                                                               |
| ip_allocation           | None                                                                                               |
| mac_address             | fa:16:3e:46:d9:ac                                                                                  |
| name                    | vtest-compile-port0                                                                                |
| network_id              | 3a3c1da0-9b3f-47bc-bccf-e5ea155f37fa                                                               |
| numa_affinity_policy    | None                                                                                               |
| port_security_enabled   | True                                                                                               |
| project_id              | 82ded64878054581a6968fdc74fe213b                                                                   |
| propagate_uplink_status | None                                                                                               |
| resource_request        | None                                                                                               |
| revision_number         | 1                                                                                                  |
| qos_network_policy_id   | None                                                                                               |
| qos_policy_id           | None                                                                                               |
| security_group_ids      | 6144d873-a31c-4665-b611-a302f59ddc2a                                                               |
| status                  | DOWN                                                                                               |
| tags                    |                                                                                                    |
| trunk_details           | None                                                                                               |
| updated_at              | 2024-10-24T20:18:23Z                                                                               |
+-------------------------+----------------------------------------------------------------------------------------------------+
```

