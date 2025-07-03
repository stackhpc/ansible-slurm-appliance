# alertmanager

Deploy [alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/)
to route Prometheus alerts to a receiver. Currently Slack is the only supported
receiver.

Note that:

- HA configuration is not supported
- Alertmanager state is not preserved when the node it runs on (by default,
  control node) is reimaged, so any alerts silenced via the GUI will reoccur.
- No Grafana dashboard for alerts is currently provided.

Alertmanager is enabled by default on the `control` node in the
[everything](../../../environments/common/layouts/everything) template which
`cookiecutter` uses for a new environment's `inventory/groups` file.

In general usage may only require:

- Adding the `control` node into the `alertmanager` group in `environments/site/groups`
  if upgrading an existing environment.
- Enabling the Slack integration (see section below).
- Possibly setting `alertmanager_web_external_url`.

The web UI is available on `alertmanager_web_external_url`.

## Role variables

All variables are optional. See [defaults/main.yml](defaults/main.yml) for
all default values.

General variables:

- `alertmanager_version`: String, version (no leading 'v')
- `alertmanager_download_checksum`: String, checksum for relevant version from
  [prometheus.io download page](https://prometheus.io/download/), in format
  `type:value`.
- `alertmanager_download_dest`: String, path of temporary directory used for
  download. Must exist.
- `alertmanager_binary_dir`: String, path of directory to install alertmanager
  binary to. Must exist.
- `alertmanager_started`: Bool, whether the alertmanager service should be started.
- `alertmanager_enabled`: Bool, whether the alertmanager service should be enabled.
- `alertmanager_system_user`: String, name of user to run alertmanager as. Will be created.
- `alertmanager_system_group`: String, name of group of alertmanager user.
- `alertmanager_port`: Port to listen on.

The following variables are equivalent to similarly-named arguments to the
`alertmanager` binary. See `man alertmanager` for more info:

- `alertmanager_config_file`: String, path the main alertmanager config file
  will be written to. Parent directory will be created if necessary.
- `alertmanager_web_config_file`: String, path alertmanager web config file
  will be written to. Parent directory will be created if necessary.
- `alertmanager_storage_path`: String, base path for data storage.
- `alertmanager_web_listen_addresses`: List of strings, defining addresses to listeen on.
- `alertmanager_web_external_url`: String, the URL under which Alertmanager is
  externally reachable - defaults to host IP address and `alertmanager_port`.
  See man page for more details if proxying alertmanager.
- `alertmanager_data_retention`: String, how long to keep data for
- `alertmanager_data_maintenance_interval`: String, interval between garbage
  collection and snapshotting to disk of the silences and the notification logs.
- `alertmanager_config_flags`: Mapping. Keys/values in here are written to the
  alertmanager commandline as `--{{ key }}={{ value }}`.
- `alertmanager_default_receivers`:

The following variables are templated into the alertmanager [main configuration](https://prometheus.io/docs/alerting/latest/configuration/):

- `alertmanager_config_template`: String, path to configuration template. The default
  is to template in `alertmanager_config_default` and `alertmanager_config_extra`.
- `alertmanager_config_default`: Mapping with default configuration for the
  top-level `route` and `receivers` keys. The default is to send all alerts to
  the Slack receiver, if that has been enabled (see below).
- `alertmanager_receivers`: A list of [receiver](https://prometheus.io/docs/alerting/)
  mappings to define under the top-level `receivers` configuration key. This
  will contain the Slack receiver if that has been enabled (see below).
- `alertmanager_extra_receivers`: A list of additional [receiver](https://prometheus.io/docs/alerting/),
  mappings to add, by default empty.
- `alertmanager_slack_receiver`: Mapping defining the [Slack receiver](https://prometheus.io/docs/alerting/latest/configuration/#slack_config). Note the default configuration for this is in
  `environments/common/inventory/group_vars/all/alertmanager.yml`.
- `alertmanager_slack_receiver_name`: String, name for the above Slack reciever.
- `alertmanager_slack_receiver_send_resolved`: Bool, whether to send resolved alerts via the above Slack reciever.
- `alertmanager_null_receiver`: Mapping defining a `null` [receiver](https://prometheus.io/docs/alerting/latest/configuration/#receiver) so a receiver is always defined.
- `alertmanager_config_extra`: Mapping with additional configuration. Keys in
  this become top-level keys in the configuration. E.g this might be:

  ```yaml
  alertmanager_config_extra:
  global:
      smtp_from: smtp.example.org:587
  time_intervals:
  - name: monday-to-friday
      time_intervals:
      - weekdays: ['monday:friday']
  ```

  Note that `route` and `receivers` keys should not be added here.

The following variables are templated into the alertmanager [web configuration](https://prometheus.io/docs/alerting/latest/https/):

- `alertmanager_web_config_default`: Mapping with default configuration for
  `basic_auth_users` providing the default web user.
- `alertmanager_alertmanager_web_config_extra`: Mapping with additional web
  configuration. Keys in this become top-level keys in the web configuration.
