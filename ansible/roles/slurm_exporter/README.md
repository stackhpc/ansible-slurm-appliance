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

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - name: Deploy Slurm exporter
      hosts: control
      become: true
      tags: slurm_exporter
      tasks:
        - import_role:
            name: slurm_exporter
          vars:
            slurm_exporter_port: 

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
