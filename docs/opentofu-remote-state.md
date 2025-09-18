# OpenTofu remote state

OpenTofu supports a number of [remote state backends](https://opentofu.org/docs/language/state/remote/)
which can be used to persist state independently of where a deployment is run.
This allows deployments to be made from anywhere that can access the state
without corrupting or conflicting with any existing resources from previous
deployments.

Using remote state is therefore strongly recommended for  environments which
should only be instantiated once, e.g. `production` and `staging`.

This page provides guidance for configuring remote states using backends
commonly available on OpenStack deployments.

> [!IMPORTANT]
> In the below replace `$ENV` with the relevant environment name.

## GitLab

GitLab can be used with the [http backend](https://opentofu.org/docs/language/settings/backends/http/)
to store separate states for each environment within the GitLab project.
Access is protected by GitLab access tokens, which in the approach below are
persisted to local files. Therefore each repository checkout will need to
authenticate separately, using either a separate token or a shared token from
some external secret store.

The below is based on the [official docs](https://docs.gitlab.com/user/infrastructure/iac/terraform_state/)
but includes some missing details and is modified for common appliance workflows.

### Initial setup

1. Create the backend file:

    ```shell
    cp environments/site/tofu/example-backends/gitlab.tf environments/$ENV/tofu
    ```

2. Modify `environments/$ENV/tofu/gitlab.tf` file to set the default for the
   project ID. This can be found by clicking the 3-dot menu at the top right of
   the GitLab project page.

    ```terraform
    # environments/$ENV/tofu/backend.tf:
    terraform {
        backend "http" {}
    }
    ```

3. Commit it.

4. Follow the per-checkout steps below.

### Per-checkout configuration

1. Create an access token in the GitLab UI, using either:

   a. If project access tokens are available, create one via
      Project > Settings > Access tokens.
      The token must have `Maintainer` role and `api` scope.

   b. Otherwise create a personal access token via
      User profile > Preferences > Access tokens.
      The token must have `api` scope.
    
   Copy the generated secret and set an environment variable:

   ```shell
   export TF_VAR_gitlab_access_token=$secret
   ```

2. If using a personal access token, set the GitLab username as an environment variable:

   ```shell
   export TF_VAR_gitlab_username=$your_username
   ```

4. With the environment activated, initialise OpenTofu.

    If no local state exists run:
    
    ```shell
    cd environments/$ENV/tofu/
    tofu init
    ```
  
    otherwise append `-migrate-state` to the `init` command to attempt to copy
    local state to the new backend.

OpenTofu is now configured to use GitLab to store state for this environment.

Repeat for each environment needing remote state.

> [!CAUTION]
> The GitLab credentials are [persisted](https://opentofu.org/docs/language/settings/backends/configuration/#credentials-and-sensitive-data)
> into a file `environments/$ENV/tofu/.terraform/terraform.tfstate` and any
> plan files. These should therefore not be committed.

### Token expiry

If the project token expires repeat the per-checkout configuration, but using
`opentofu init -reconfigure` instead.

## S3

For clouds with S3-compatible object storage (e.g. Ceph with [radosgw](https://docs.ceph.com/en/latest/radosgw/))
the S3 backend can be used. This approach uses a bucket per environment.

With the environment activated:

1. Create a bucket:

    ```shell
    export TF_STATE_NAME="$(basename $APPLIANCES_ENVIRONMENT_ROOT)"
    openstack container create $TF_STATE_NAME

2. Create credentials:

    ```shell
    openstack ec2 credentials create
    ```

    From the returned values, set:
    
    ```shell
    export AWS_ACCESS_KEY_ID= # "access" value
    export AWS_SECRET_ACCESS_KEY= # "secret" value
    ```

    Note these are available any time by running:

    ```shell
    openstack ec2 credentials list
    ```

    TODO: Think about automating these into the activate script??

3. Create a backend file and commit it, for example:

    ```terraform
    # environments/$ENV/tofu/backend.tf:
    terraform {
        backend "s3" {
            endpoint = "leafcloud.store"
            bucket = "$ENV" # ** replace with environment name **
            key    = "environment.tfstate"
            region = "dummy"
            
            skip_region_validation = true
            skip_credentials_validation = true
            force_path_style = true
        }
    }
    ```

    Note that:
    - `endpoint` is the radosgw address. If not known this can be determined by
      creating a public bucket, and then getting the URL using
      Project > Containers > (your public container) > Link, which provides an
      URL of the form `https://$ENDPOINT/swift/...`.
      `/swift`.
    - `region` is required but not used in radosgw, hence `skip_region_validation`.
    - `key` is an arbitrary state file name
    - `skip_credentials_validation`: Disables STS - this may or may not be
      required depending on the radosgw configuration.
    - `force_path_style`: May or may not be required depending on the radosgw
      configuration.
      
4. Run:

    ```shell
    tofu init
    ```

    OpenTofu is now configured to use the cloud's S3 to store state for this
    environment.


TODO: consider bucket versioning??
TODO: consider whether we should use a single bucket for both stg and prd to make
testing better??

TODO: understand -reconfigure vs -migrate-state?
