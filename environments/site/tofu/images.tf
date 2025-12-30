locals {
  image_ids = jsondecode(file("${path.module}/../images/community_image_ids.json"))
}
