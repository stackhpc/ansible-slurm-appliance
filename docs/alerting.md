# Alerting

The [prometheus.io docs](https://prometheus.io/docs/alerting/latest/overview/)
describe the overall alerting process:

> Alerting with Prometheus is separated into two parts. Alerting rules in
  Prometheus servers send alerts to an Alertmanager. The Alertmanager then
  manages those alerts, including silencing, inhibition, aggregation and
  sending out notifications via methods such as email, on-call notification
  systems, and chat platforms.

By default, both a `prometheus` server and an `alertmanager` server are
deployed on the control node for new environments:

```ini
# environments/site/groups:
[prometheus:children]
control

[alertmanager:children]
control
```

The general Prometheus configuration is described in
[monitoring-and-logging.md](./monitoring-and-logging.md#defaults-3) - note this
section specifies some role variables which commonly need modification.

The alertmanager server is defined by the [ansible/roles/alertmanager](../ansible/roles/alertmanager/README.md),
and all the configuration options and defaults are defined there. By default
it will be fully functional but:
- `alertmanager_web_external_url` is likely to require modification.
- A [receiver](https://prometheus.io/docs/alerting/latest/configuration/#receiver)
  must be defined to actually provide notifications. Currently a Slack receiver
  integration is provided (see below) but alternative receivers
  could be defined using the provided role variables.

## Slack receiver

This section describes how to enable the Slack receiver to provide notifications
of alerts via Slack.

1. Create an app with a bot token:

- Go to https://api.slack.com/apps
- select "Create an App"
- select "From scratch"
- Set app name and workspace fields, select "Create"
- Fill out "Short description" and "Background color" fields, select "Save changes"
- Select "OAuth & Permissions" on left menu
- Under "Scopes : Bot Token Scopes", select "Add an OAuth Scope", add
  `chat:write` and select "Save changes"
- Select "Install App" on left menu, select "Install to your-workspace", select Allow
- Copy the Bot User OAuth token shown

2. Add the bot token into the config and enable Slack integration:

- Open `environments/$ENV/inventory/group_vars/all/vault_alertmanager.yml`
- Uncomment `vault_alertmanager_slack_integration_app_creds` and add the token
- Vault-encrypt that file:

        ansible-vault encrypt environments/$ENV/inventory/group_vars/all/vault_alertmanager.yml

- Open `environments/$ENV/inventory/group_vars/all/alertmanager.yml`
- Uncomment the `alertmanager_slack_integration` mapping and set your alert channel name

3. Invite the bot to your alerts channel
- In the appropriate Slack channel type:

        /invite @YOUR_BOT_NAME


## Alerting Rules

These are part of [Prometheus configuration](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)
which is defined appliance at
[environments/common/inventory/group_vars/all/prometheus.yml](../environments/common/inventory/group_vars/all/prometheus.yml).

Two `cloudalchemy.prometheus` role variables are relevant:
- `prometheus_alert_rules_files`: Paths to check for files providing rules.
  Note these are copied to Prometheus config directly, so jinja expressions for
  Prometheus do not need escaping.
- `prometheus_alert_rules`: Yaml-format rules. Jinja templating here will be
interpolated by Ansible, so templating intended for Prometheus must be escaped
using `{% raw %}`/`{% endraw %}` tags.

By default, `prometheus_alert_rules_files` is set so that any `*.rules` files
in a directory `files/prometheus/rules` in the current environment or *any*
parent environment are loaded. So usually, site-specific alerts should be added
by creating additional rules files in `environments/site/files/prometheus/rules`.
If the same file exists in more than one environment, the "child" file will take
precedence and any rules in the "parent" file will be ignored.

A set of default alert rule files is provided at `environments/common/files/prometheus/rules/`.
These cover:
- Some node-exporter metrics for disk, filesystems, memory and clock. Note
  no alerts are triggered on memory for compute nodes due to the intended use
  of those nodes.
- Slurm nodes in DOWN or FAIL states, or the Slurm DBD message queue being too
  large, usually indicating a database problem.

When defining additional rules, note the [labels defined](./monitoring-and-logging.md#prometheus_node_exporter_targets) for node-exporter targets.

In future more alerts may be added for:
- smartctl-exporter-based rules for baremetal nodes where there is no
  infrastructure-level smart monitoring
- loss of "up" network interfaces
