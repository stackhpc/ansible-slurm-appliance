variable "s3_backend_endpoint" {
  type        = string
  description = "radosgw address without protocol or path e.g. leafcloud.store"
  #default = # add here
}

# tflint-ignore: terraform_required_version
terraform {
  backend "s3" {
    endpoint = var.s3_backend_endpoint
    bucket   = "${var.cluster_name}-${basename(var.environment_root)}-tfstate"
    key      = "environment.tfstate"

    # Reginon is required but not used in radosgw:
    region                 = "dummy"
    skip_region_validation = true

    # Normally STS is not configured in radosgw:
    skip_credentials_validation = true

    # Enable path-style S3 URLs (https://<HOST>/<BUCKET> instead of https://<BUCKET>.<HOST>)
    # may or may not be required depending on radosgw configuration
    use_path_style = true
  }
}
