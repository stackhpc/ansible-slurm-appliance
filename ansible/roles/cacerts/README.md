# cacerts

Configure CA certificates and trusts.

## Role variables

- `ca-certificates`: Optional str. Path to directory containing certificates
  in PEM or DER format. Any files here will be added to the list of CAs trusted
  by the system.

Note: This role assumes the `ca-certificates` dnf package is installed, which
is the case for GenericCloud-based images.
