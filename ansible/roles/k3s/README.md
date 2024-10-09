k3s
=====

Installs k3s agent and server services on nodes and an ansible-init playbook to activate them. The service that each node will activate on init is determined by OpenStack metadata. Also includes Helm install. Currently only supports a single k3s-server
(i.e one control node). Install based on the [official k3s ansible role](https://github.com/k3s-io/k3s-ansible).


Requirements
------------

`azimuth_cloud.image_utils.linux_ansible_init` must have been run previously on targeted nodes

Role Variables
--------------

- `k3s_version`: Optional str. K3s version to install, see [official releases](https://github.com/k3s-io/k3s/releases/).
