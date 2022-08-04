data "openstack_images_image_v2" "nodes" {
  for_each = var.image_names
  
  name = each.value
}
