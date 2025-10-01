variable "gitlab_username" {
  type        = string
  description = <<-EOF
        Username of actual GitLab user, for personal access token only.
        Default uses bot account name, for project access token.
    EOF
  default     = null
}

variable "gitlab_access_token" {
  type        = string
  description = <<-EOF
        GitLab Project or Personal access token.
        Must have Maintainer role (for Project token) and API scope
    EOF
}

variable "gitlab_project_id" {
  type        = string
  description = "GitLab project ID - click 3-dot menu at the top right of project page"
  #default = # add here
}

locals {
  gitlab_username      = coalesce(var.gitlab_username, "project_${var.gitlab_project_id}_bot")
  gitlab_state_name    = basename(var.environment_root)
  gitlab_state_address = "https://gitlab.com/api/v4/projects/${var.gitlab_project_id}/terraform/state/${local.gitlab_state_name}"
}

# tflint-ignore: terraform_required_version
terraform {
  backend "http" {
    address        = local.gitlab_state_address
    lock_address   = "${local.gitlab_state_address}/lock"
    unlock_address = "${local.gitlab_state_address}/lock"
    username       = local.gitlab_username
    password       = var.gitlab_access_token
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}
