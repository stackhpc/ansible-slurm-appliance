This is pretty subtle.

- secrets always need to be idempotent
- caas cannot run a pre-task to create files in inventory, so secrets
  need to be loaded as part of site
- caas cannot write inventory, b/c that is in a container which is new each
  run


TODO:
- remove the adhoc generate-passwords from non-caas
- remove and the other role/hook from caas and the secret overrides
- work out how we'd migrate secrets for caas????
- test it properly
- doc this role properly
