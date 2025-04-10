# alertmanager


notes:
- HA is not supported
- state ("notification state and configured silences") is not preserved across rebuild
- not used for caas
- no dashboard



## Role variables

The following variables are equivalent to similarly-named arguments to the
`alertmanager` binary. See `man alertmanager` for more info:

- TODO:

The following variables are templated into the alertmanager configuration file:

- TODO:

Other variables:
- TODO:


## TODO

memory usage looks a bit close:

```
[root@RL9-control rocky]# free -h
               total        used        free      shared  buff/cache   available
Mem:           3.6Gi       2.4Gi       168Mi        11Mi       1.5Gi       1.2Gi
Swap:             0B          0B          0B
```



## Slack Integration

1. Create an app with a bot token:

- Go to https://api.slack.com/apps
- select "Create an App"
- select "From scratch"
- Set app name and workspacef fields, select "Create"
- Fill out "Short description" and "Background color" fields, select "Save changes"
- Select "OAuth & Permissions" on left menu
- Under "Scopes : Bot Token Scopes", select "Add an OAuth Scope", add
  `chat:write` and select "Save changes"
- Select "Install App" on left menu, select "Install to your-workspace", select Allow
- Copy the Bot User OAuth token shown

2. Add the bot token into the config and enable Slurm integration

- Open `environments/site/inventory/group_vars/all/vault_alertmanager.yml`
- Uncomment `vault_alertmanager_slack_integration_app_creds` and add the token
- Vault-encrypt that file:

    ansible-vault encrypt environments/$ENV/inventory/group_vars/all/vault_alertmanager.yml

- Open `environments/site/inventory/group_vars/all/alertmanager.yml`
- Uncomment the config and set your alert channel name

3. Invite the bot to your alerts channel
- In the appropriate Slack channel type:

    /invite @YOUR_BOT_NAME


## Adding Rules

TODO: describe how prom config works