# OpenTofu remote state

OpenTofu supports a number of [remote state backends](https://opentofu.org/docs/language/state/remote/)
which can be used to persist state independently of where a deployment is run.
This allows deployments to be made from anywhere that can access the state
without corrupting or conflicting with any existing resources from previous
deployments.

Using remote state is therefore strongly recommended for environments which
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

2. Modify `environments/$ENV/tofu/gitlab.tf` to set the default for the
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

3. With the environment activated, initialise OpenTofu.

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
the S3 backend can be used. This approach uses a bucket per environment and
derives credentials from OpenStack credentials, meaning no backend-specific
per-checkout configuration is required.

### Initial setup

1. Create an S3 bucket with a name `${cluster_name}-${environment_name}-tfstate`
   where:
   - `CLUSTER_NAME` is defined in `environments/$ENV/tofu/main.tf`
   - `$ENVIRONMENT_NAME` is the name of the environment directory

   e.g.

   ```shell
   openstack container create research-staging-tfstate
   ```

2. Create `ec2` credentials:

   ```shell
   openstack ec2 credentials create
   ```

3. Create the backend file:

   ```shell
   cp environments/site/tofu/example-backends/s3.tf environments/$ENV/tofu
   ```

4. Modify `environments/$ENV/tofu/s3.tf` to set the default for `s3_backend_endpoint`.
   This is the radosgw address. If not known it can be determined by creating a
   public bucket, and then getting the URL using
   Project > Containers > (your public bucket) > Link
   which provides a URL of the form `https://$ENDPOINT/swift/...`.

5. Add the following to `environments/$ENV/activate`:

   ```bash
   # Get current openstack project:
   TOKEN_DATA=$(openstack token issue -f json)
   PROJECT_ID=$(echo "$TOKEN_DATA" | jq -r '.project_id')
   TOKEN_ID=$(echo "$TOKEN_DATA" | jq -r '.id')
   openstack token revoke $TOKEN_ID

   # Get first creds in current project:
   EC2_CREDS=$(openstack ec2 credentials list -f json | jq -r --arg pid "$PROJECT_ID" '.[] | select(.["Project ID"] == $pid) | @json' | head -n 1)
   # Set creds for OpenTofu s3 backend:
   export AWS_ACCESS_KEY_ID=$(echo "$EC2_CREDS" | jq -r '.Access')
   export AWS_SECRET_ACCESS_KEY=$(echo "$EC2_CREDS" | jq -r '.Secret')
   ```

   This avoids these credentials being persisted in local files.

6. Copy the lines above into your shell to set them for your current shell.

7. With the environment activated, initialise OpenTofu.

   If no local state exists run:

   ```shell
   cd environments/$ENV/tofu/
   tofu init
   ```

   otherwise append `-migrate-state` to the `init` command to attempt to copy
   local state to the new backend.

8. If this fails, try setting `use_path_style = true` in `environments/$ENV/tofu/s3.tf`.

9. Once it works, commit `environments/$ENV/tofu/s3.tf` and `environments/$ENV/activate`.

OpenTofu is now configured to use the cloud's S3-compatible storage to store
state for this environment.

Repeat for each environment needing remote state.

For more configuration options, see the OpenTofu [s3 backend docs](https://opentofu.org/docs/language/settings/backends/s3/).

### Per-checkout configuration

EC2 credentials are per-user and per-project. Check you have credentials for
the current project using:

```shell
openstack ec2 credentials list # to show credentials
openstack project list         # to show project IDs
```

and if not, create them:

```shell
openstack ec2 credentials create
```

The ec2 credentials will then automatically be loaded when activating the
environment. For a new checkout simply initialise OpenTofu as normal as
described in step 7 above.
