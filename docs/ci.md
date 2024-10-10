# CI/CD automation

The `.github` directory contains a set of sample workflows which can be used by downstream site-specific configuration repositories to simplify ongoing maintainence tasks. These include:

- An [upgrade check](.github/workflows/upgrade-check.yml.sample) workflow which automatically checks this upstream stackhpc/ansible-slurm-appliance repo for new releases and proposes a pull request to the downstream site-specific repo when a new release is published.

- An [image upload](.github/workflows/upload-s3-image.yml.sample) workflow which takes an image name, downloads it from StackHPC's public S3 bucket if available, and uploads it to the target OpenStack cloud.

