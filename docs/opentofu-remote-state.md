# OpenTofu remote state

OpenTofu supports a number of [remote state backends](https://opentofu.org/docs/language/state/remote/)
which can be used to persist state independently of where a deployment is run.
This allows deployments to be made from anywhere that can access the state
without corrupting or conflicting with any existing resources from previous
deployments.

Using remote state is therefore strongly recommended for  environments which
should only be instantiated once, e.g. `production` and `staging`.

This page provides some guidance for configuring remote states using
commonly-available backends.

> [!IMPORTANT]
> In the below replace `$ENV` with the relevant environment name.

## GitLab

With the environment activated:

1. Create a backend file and commit it:

    ```terraform
    # environments/$ENV/tofu/backend.tf:
    terraform {
        backend "http" {}
    }
    ```

2. Create a personal access token with API access (note Project tokens do not
   appear to work):
   
   TODO: appears maybe the do with `project_$ID_bot` as the username
   
   - In GitLab, click on your user button at top left and select 'Preferences'.
   - Select 'Access tokens', 'Add new token'.
   - Optionally set an expiry date, select 'API' scope and click 'Create token'.
   - Copy the generated secret and set an environment variable in your terminal
        ```shell
        export TF_PASSWORD=$SECRET
        ```

    TODO: how does this get persisted??

3. Create this script and commit it:

    ```shell
    # environments/$ENV/tofu/init-gitlab-backend.sh
    PROJECT_ID="<gitlab-project-id>"
    TF_USERNAME="<gitlab-username>"
    TF_STATE_NAME="$(basename $APPLIANCES_ENVIRONMENT_ROOT)"
    TF_ADDRESS="https://gitlab.com/api/v4/projects/${PROJECT_ID}/terraform/state/${TF_STATE_NAME}"

    tofu init \
    -backend-config=address=${TF_ADDRESS} \
    -backend-config=lock_address=${TF_ADDRESS}/lock \
    -backend-config=unlock_address=${TF_ADDRESS}/lock \
    -backend-config=username=${TF_USERNAME} \
    -backend-config=password=${TF_PASSWORD} \
    -backend-config=lock_method=POST \
    -backend-config=unlock_method=DELETE \
    -backend-config=retry_wait_min=5
    ```

    The project id can be found by clicking the 3-dot menu at the top right of
    the GitLab project page.

4. Run the script:

    ```shell
    cd environments/$ENV/tofu/
    source init-gitlab-backend.sh
    ```
    
OpenTofu is now configured to use GitLab to store state for this environment.

Repeat for each environment needing remote state.

If the project token expires repeat the above but with the option `-reconfigure`
added to the script.

> [!CAUTION]
> The GitLab credentials are [persisted](https://opentofu.org/docs/language/settings/backends/configuration/#credentials-and-sensitive-data)
> into a file `environments/$ENV/tofu/.terraform/terraform.tfstate` and any
> plan files. These should therefore not be committed.

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
