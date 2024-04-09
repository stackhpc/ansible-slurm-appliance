# Sussex-Lab cluster

Configuration for the Sussex lab environment on Leafcloud.

This requires the following resources to be provided:
- A volume named `sussexlab-state`
- A volume name `sussexlab-home`
- A FIP which must be defined as the `fip` attribute for the login node in Tofu variable
`login_nodes`.
- Networks and subnets - see Tofu variables `tenant_*` and `storage_*`: **NB:** The
`storage_` subnet must NOT have a default gateway.
