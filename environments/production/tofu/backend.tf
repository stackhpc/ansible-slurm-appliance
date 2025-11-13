terraform {
  backend "s3" {
    endpoint = "https://api.dl.acrc.bris.ac.uk:6780"
    key = "terraform.tfstate"
    bucket = "slurm-production-tofu-state"
    # Ceph doesn't use the region, but OpenTofu requires it
    region = "not-used-but-required"
    skip_region_validation = "true"
    # The STS API doesn't exist for Ceph
    skip_credentials_validation = "true"
    use_path_style = "true"
  }
}
