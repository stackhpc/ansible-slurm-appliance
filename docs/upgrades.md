# Upgrades

This document explains the generic steps required to upgrade a deployment of the Slurm Appliance with upstream changes from StackHPC.
Generally, upstream releases will happen roughly monthly. Releases may contain new functionality and/or updated images.

Any site-specific instructions in [docs/site/README.md](site/README.md) should be reviewed in tandem with this.

This document assumes the deployment repository has:
1. Remotes:
    - `origin` referring to the site-specific remote repository.
    - `stackhpc` referring to the StackHPC repository at https://github.com/stackhpc/ansible-slurm-appliance.git.
2. Branches:
    - `main` - following `main/origin`, the current site-specific code deployed to production.
    - `upstream` - following `main/stackhpc`, i.e. the upstream `main` branch from `stackhpc`.
3. The following environments:
    - `$PRODUCTION`: a production environment, as defined by e.g. `environments/production/`.
    - `$STAGING`: a production environment, as defined by e.g. `environments/staging/`.
    - `$SITE_ENV`: a base site-specific environment, as defined by e.g. `environments/mysite/`.

**NB:** Commands which should be run on the Slurm login node are shown below prefixed `[LOGIN]$`.
All other commands should be run on the Ansible deploy host.

1. Update the `upstream` branch from the `stackhpc` remote, including tags:

        git fetch stackhpc main --tags

1. Identify the latest release from the [Slurm appliance release page](https://github.com/stackhpc/ansible-slurm-appliance/releases). Below this is shown as `vX.Y`, which is the 

1. Ensure your local site branch is up to date and create a new branch from it for the
   site-specfic release code:

        git checkout main
        git pull --prune
        git checkout -b update/vX.Y

1. Merge the upstream code into your release branch:

        git merge vX.Y

   It is possible this will introduce merge conflicts; fix these following the usual git 
   prompts. Generally merge conflicts should only exist where functionality which was added
   for your site (not in a hook) has subsequently been merged upstream.

1. Push this branch and create a PR:

        git push
        # follow instructions

1. Review the PR to see if any added/changed functionality requires alteration of
   site-specific configuration. In general changes to existing functionality will aim to be
   backward compatible. Alteration of site-specific configuration will usually only be
   necessary to use new functionality or where functionality has been upstreamed as above.

   Make changes as necessary.

1. Identify image(s) from the relevant [Slurm appliance release](https://github.com/stackhpc/ansible-slurm-appliance/releases), and download
   using the link on the release plus the image name, e.g. for an image `openhpc-ofed-RL8-240906-1042-32568dbb`:

        wget https://object.arcus.openstack.hpc.cam.ac.uk/swift/v1/AUTH_3a06571936a0424bb40bc5c672c4ccb1/openhpc-images/openhpc-ofed-RL8-240906-1042-32568dbb

    Note that some releases may not include new images. In this case use the image from the latest previous release with new images.

1. If required, build an "extra" image with local modifications, see [docs/image-build.md](./image-build.md).

1. Modify your site-specific environment to use this image, e.g. via `cluster_image_id` in `environments/$SITE_ENV/terraform/variables.tf`.

1. Test this in your staging cluster.

1. Commit changes and push to the PR created above.

1. Declare a future outage window to cluster users. A [Slurm reservation](https://slurm.schedmd.com/scontrol.html#lbAQ) can be
   used to prevent jobs running during that window, e.g.:

        [LOGIN]$  sudo scontrol create reservation Flags=MAINT ReservationName="upgrade-vX.Y" StartTime=2024-10-16T08:00:00 EndTime=2024-10-16T10:00:00 Nodes=ALL Users=root

   Note a reservation cannot be created if it may overlap with currently running jobs (defined by job or partition time limits).

1. At the outage window, check there are no jobs running:

        [LOGIN]$ squeue

1. Deploy the branch created above to production, i.e. activate the production environment, run OpenTofu to reimage or
delete/recreate instances with the new images (depending on how the root disk is defined), and run Ansible's `site.yml`
playbook to reconfigure the cluster, e.g. as described in the main [README.md](../README.md).

1. Check slurm is up:

        [LOGIN]$ sinfo -R
   
   The `-R` shows the reason for any nodes being down.

1. If the above shows nodes done for having been "unexpectedly rebooted", set them up again:

        [LOGIN]$ sudo scontrol update state=RESUME nodename=$HOSTLIST_EXPR

    where the hostlist expression might look like e.g. `general-[0-1]` to reset state for nodes 0 and 1 of the general partition.

1. Delete the reservation:

        [LOGIN]$ sudo scontrol delete ReservationName="upgrade-slurm-v1.160"

1. Tell users the cluster is available again.

