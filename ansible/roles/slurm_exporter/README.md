slurm_exporter
==============

Build, install and configure a Prometheus exporter for metrics about Slurm itself: https://github.com/vpenso/prometheus-slurm-exporter/

Requirements
------------

Rocky Linux 8.5 host.

Role Variables
--------------

See `defaults/main.yml`

Dependencies
------------

None.

Example Playbook
----------------

    - name: Deploy Slurm exporter
      hosts: control
      become: true
      tags: slurm_exporter
      tasks:
        - import_role:
            name: slurm_exporter

Prometheus scrape configuration for this might look like:

```
- job_name: "slurm_exporter"
  scrape_interval: 30s
  scrape_timeout: 30s
  static_configs:
    - targets:
      - "{{ openhpc_slurm_control_host }}:9341"
```

License
-------

Apache v2

Author Information
------------------

StackHPC Ltd.
