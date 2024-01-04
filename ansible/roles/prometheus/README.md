# prometheus
Creates a systemd service `prometheus` which uses the `podman` user to run a containerised [Prometheus](https://github.com/prometheus/prometheus) monitoring system.

Note this contains two task books:
    - `install.yml`: This is safe to run during a Packer build. It pulls the container image and creates the systemd unit file.
    - `runtime.yml`: This cannot be run during a Packer build. It templates out config and restarts/starts the service as required.

## Role Variables

See `defaults/main.yml`. All variables can be updated by running `runtime.yml`, except the below which require `install.yml` to be run to update:
- `prometheus_storage_retention_size`
- `prometheus_storage_retention`
