# Slurm REST API

Slurm is controllable over an HTTP [REST API](https://slurm.schedmd.com/rest.html)
via the `slurmrestd` service.

This requires the `auth/jwt` alternate authentication mechanism in Slurm and is supported
by the [ansible-role-openhpc](https://github.com/stackhpc/ansible-role-openhpc) role.

## Enabling the REST API

Add host(s) to the **slurmrestd** group. It is recommended to use either a separate host, or the
host running Open OnDemand.

This will automatically enable JWT as an alternate method of authentication.

Add the `vault_openhpc_jwt_key_b64` secret to your environment's secrets:

```shell
ansible-vault decrypt environments/staging/inventory/group_vars/all/secrets.yml
ansible-playbook ansible/adhoc/generate-passwords.yml
ansible-vault encrypt environments/staging/inventory/group_vars/all/secrets.yml
```

## Enabling the reverse proxy

slurmrestd is configured to listen on `127.0.0.1` by default (`openhpc_slurmrestd_listen_endpoints`)
and the reverse proxy is enabled by default (`appliances_enable_slurmrestd_proxy`).

It supports the same Let's Encrypt integration as the openondemand role and will use the same
self-signed certificate by default.

If running on the same host as Open OnDemand, it needs a different hostname for httpd routing.
Set `slurmrestd_proxy_servername` to the chosen FQDN.

See [../ansible/roles/slurmrestd_proxy/README.md](../ansible/roles/slurmrestd_proxy/README.md) for more details.
