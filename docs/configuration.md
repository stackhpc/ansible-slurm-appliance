# Configuration

This page provides configuration snippets for various services.

## Chrony

Use variables from the [mrlesmithjr.chrony](https://github.com/mrlesmithjr/ansible-chrony) role.

For example in: `environments/<environment>/inventory/group_vars/all/chrony`:

```
---
chrony_ntp_servers:
  - server: ntp-0.example.org
    options:
      - option: iburst
      - option: minpoll
        val: 8
  - server: ntp-1.example.org
    options:
      - option: iburst
      - option: minpoll
        val: 8

```
