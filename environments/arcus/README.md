Provides a CI environment on Arcus in the `rcp-cloud-portal-demo` project. Uses "direct"-mode VNICs.

This can be deployed manually on Arcus but will require the following to be defined:
- Terraform variables `cluster_name` and `base_image_name`. E.g.:

    ```
    environments/smslabs/terraform/terraform.tfvars:
    cluster_name = "ofed"
    base_image_name = "openhpc-220510-1911-ofed.qcow2"
    ```
- Ansible variable `vault_testuser_password` defining the password for `testuser` (used for accessing Open Ondemand), e.g.:
    ```
    environments/smslabs/inventory/group_vars/all/dev.yml:
    vault_testuser_password: somesecretstring
    ```
