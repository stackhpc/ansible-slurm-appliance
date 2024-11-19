# Receiving alert notifications

The appliance uses [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) to route Prometheus alerts to site receivers. See the [monitoring docs](monitoring-and-logging.md#alerting-and-recording-rules) for configuring custom Prometheus alerts.

A default Slack alert receiver configuration is provided in
> [environments/common/inventory/group_vars/all/alertmanager.yml](../environments/common/inventory/group_vars/all/alertmanager.yml)

which can be enabled by uncommenting the `alertmanager_slack_integration` and providing application credentials for a Slack app with `chat:write` permissions for the channel you wish to receive alerts in (see [Slack app](https://api.slack.com/quickstart) docs for configuration).
