locals {
  image_ids = jsondecode(file("${path.module}/../images/image_ids.json"))
}
