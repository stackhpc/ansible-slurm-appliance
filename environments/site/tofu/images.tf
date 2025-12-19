locals {
  image_ids = jsondecode(file("${path.module}/cluster_images.json"))
}
