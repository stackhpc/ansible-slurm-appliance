# Common configuration

This contains an inventory that defines variables which are common between the
`production` and `development` environments. It is not intended to be used in
a standalone fashion to deploy infrastructure (i.e no tofu), but is instead
referenced in `ansible.cfg` from the `production` and `development` configurations.

The pattern we use is that all resources referenced in the inventory
are located in the environment directory containing the inventory that
references them. For example, the file referenced in `inventory/group_vars/prometheus/defaults.yml`
using the variable `prometheus_alert_rules_files` references a file in the
`files` directory relative to this one.
