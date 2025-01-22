# compute-init

See the role README.md

# Changes to image / tofu state

When a compute group has the `ignore_image_changes` parameter set to true,
changes to the `image_id` parameter (which defaults to `cluster_image_id`) are
ignored by OpenTofu.

Regardless of whether `ignore_image_changes` is set, OpenTofu templates out the
`image_id` into the Ansible inventory for each compute node. The `compute_init`
role templates out hostvars to the control node, which means the "target" image
ID is then available on the control node. Subsequent work will use this to
rebuild the node via slurm.

# CI workflow

The compute node rebuild is tested in CI after the tests for rebuilding the
login and control nodes. The process follows

1. Compute nodes are reimaged:

         ansible-playbook -v --limit compute ansible/adhoc/rebuild.yml

2. Ansible-init runs against newly reimaged compute nodes

3. Run sinfo and check nodes have expected slurm state

         ansible-playbook -v ansible/ci/check_slurm.yml