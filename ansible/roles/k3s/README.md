k3s
=====

Installs k3s agent and server services on nodes and an ansible-init playbook to activate them. The service that each node will activate on init is determined by OpenStack metadata. Also includes Helm install. Currently only supports a single k3s-server
(i.e one control node). Install based on the [official k3s ansible role](https://github.com/k3s-io/k3s-ansible).


Requirements
------------

`azimuth_cloud.image_utils.linux_ansible_init` must have been run previously on targeted nodes during image build.

Role Variables
--------------

- `k3s_version`: Optional str. K3s version to install, see [official releases](https://github.com/k3s-io/k3s/releases/).


Development
-----------

It is possible to work on Ansible in this role without having to build and
deploy an image.

1. Deploy/update instances using `tofu apply`. Note this can also change e.g.
   metadata.

2. Modify e.g. `tasks/install` or `files/start_k3s`

3. Run either:

        ansible-playbook ansible/bootstrap --tags k3s

   If no networking configuration is required at all, or

        ansible-playbook ansible/bootstrap

4. For the latter, if Ansible hangs on:

        TASK [Wait for ansible-init to finish]

   e.g. because an existing k3s installation is broken, run

        ansible k3s -ba "touch /var/lib/ansible-init.done"

5. Remove the ansible-init sentinel file:

        ansible k3s -ba "rm -f /var/lib/ansible-init.done"

6. Restart ansible-init - note this is a one-shot service so a `start` will do
   nothing if systemd thinks it has already run.

        ansible k3s -ba "systemctl restart ansible-init"

7. On a node, inspect ansible-init logs (and syslog if necessary):

        journalctl -xeu ansible-init

8. Repeat as necessary. In some cases resetting the cluster to unmodified disks
   may be useful:

        ansible-playbook ansible/adhoc/rebuild.yml
