# OpenTofu remote state

Generally, using [remote state](https://opentofu.org/docs/language/state/remote/)
is recommended.

This can be configured by adding additional files into the
`environments/{production,staging,...}/tofu` directories. Some guidance for
different backends is given here.


## GitLab

The following creates a state per environment.

1. Create a backend file and commit it:

    ```terraform
    # environments/$ENV/tofu/backend.tf:
    terraform {
    backend "http" {}
    }
    ```

2. Create a personal access token with API access (note Project tokens do not
   appear to work):
   - In GitLab, click on your user button at top left and select 'Preferences'.
   - Select 'Access tokens', 'Add new token'.
   - Optionally set an expiry date, select 'API' scope and click 'Create token'.
   - Copy the generated secret and set an environment variable in your terminal:
   
        ```shell
        export TF_PASSWORD=$SECRET
        ```

3. Create this script and commit it:
   it:

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

4. With the environment activated, run the script:

    ```shell
    cd environments/$ENV/tofu/
    source init-gitlab-backend.sh
    ```
    
    OpenTofu is now configured to use GitLab to store state for this environment.

Repeat for each environment needing remote state. Generally, `dev` environments
will be personal so should not need this.

If the project token expires, follow the above again by add an option `-reconfigure`
to the script.

## S3

TODO.
