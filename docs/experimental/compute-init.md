# compute-init

See the role README.md

# Changes to image / tofu state

When a compute group has ignore_image_changes set as true in a compute group
partition within tofu/main.tf, and the image is updated:

Subsequent changes to the tf cluster_image variable for that compute group don’t
actually result in a change via tofu plan/apply. This is done with the
lifecycle meta-argument "ignore_changes" in the compute resource.

As part of compute-init, the image_id is templated out to hostvars so that
ansible will have image_id for each compute node.

WIP:    Attempts to change the cluster image from tofu then act as a target
        for compute-init to read and rebuild to via slurm control.

# CI workflow

The compute node rebuild is tested in CI after the tests for rebuilding the
login and control nodes. The process follows

1. Compute nodes are reimaged:

         ansible-playbook -v --limit compute ansible/adhoc/rebuild.yml

2. Ansible-init runs against newly reimaged compute nodes

3. Run sinfo and check nodes have expected slurm state

         ansible-playbook -v ansible/ci/check_slurm.yml