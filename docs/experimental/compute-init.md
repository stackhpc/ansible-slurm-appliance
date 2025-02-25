# compute-init

See the role README.md

# CI workflow

The compute node rebuild is tested in CI after the tests for rebuilding the
login and control nodes. The process follows

1. Compute nodes are reimaged:

         ansible-playbook -v --limit compute ansible/adhoc/rebuild.yml

2. Ansible-init runs against newly reimaged compute nodes

3. Run sinfo and check nodes have expected slurm state

         ansible-playbook -v ansible/ci/check_slurm.yml