tuned
=========

This role configures the TuneD tool for system tuning, ensuring optimal performance based on the profile settings defined.

Role Variables
--------------

See the [TuneD documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/monitoring_and_managing_system_status_and_performance/getting-started-with-tuned_monitoring-and-managing-system-status-and-performance) for profile details.


- `tuned_profile_baremetal`: Optional str. Name of default profile for non-virtualised hosts. Default `hpc-compute`.
- `tuned_profile_vm`: Optional str. Name of default profile for virtualised hosts. Default `virtual-guest`.
- `tuned_profile`: Optional str. Name of profile to apply to host. Defaults to `tuned_profile_baremetal` or `tuned_profile_vm` as appropriate.
