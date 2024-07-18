tuned
=========

This role configures the TuneD tool for system tuning, ensuring optimal performance based on the profile settings defined.

Role Variables
--------------

The profiles provided with tuned are divided into two categories: power-saving profiles, and performance-boosting profiles. The performance-boosting profiles include profiles focus on the following aspects:
 - low latency for storage and network
 - high throughput for storage and network
 - virtual machine performance
 - virtualization host performance

See the [TuneD documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/monitoring_and_managing_system_status_and_performance/getting-started-with-tuned_monitoring-and-managing-system-status-and-performance) for profile details.


- `tuned_profile_baremetal: hpc-compute` 
- `tuned_profile_vm: virtual-guest`
- `tuned_profile: "{{ tuned_profile_baremetal if ansible_virtualization_role != 'guest' else tuned_profile_vm }}"`
- `tuned_enabled: true`
- `tuned_started: true`

To list all available profiles and identify the current active profile, run on-node:

`tuned-adm list`

To only display the currently active profile, run:

`tuned-adm active`

To switch to one of the available profiles, run:

`tuned-adm profile {profile_name}`

