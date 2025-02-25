# Overview
A K3s cluster is deployed with the Slurm cluster. Both an agent and server instance of K3s is installed during image build and the correct service (determined by OpenStack metadata) will be 
enabled during boot. Nodes with the `k3s_server` metadata field defined will be configured as K3s agents (this field gives them the address of the server). The Slurm control node is currently configured as a server while all other nodes are configured as agents. Using multiple K3s servers isn't supported. Currently only the root user on the control node has 
access to the Kubernetes API. The `k3s` role installs Helm for package management. K9s is also installed in the image and can be used by the root user.

# Idempotency
K3s is intended to only be installed during image build as it is configured by the appliance on first boot with `azimuth_cloud.image_utils.linux_ansible_init`. Therefore, the `k3s` role isn't
idempotent and changes to variables will not be reflected in the image when running `site.yml`.
