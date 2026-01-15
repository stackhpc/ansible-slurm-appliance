# OpenPortal

## Role Variables

- `openportal_binaries_dir`: **Required** the local path to a directory containing the compiled OpenPortal binaries
- `openportal_start_services` (default is `false`): should the systemd services be started
- `openportal_services`: a mapping of all the OpenPortal services to start, along with their configuration
