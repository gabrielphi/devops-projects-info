resource "mgc_ssh_keys" "my_key" {
  provider = mgc.nordeste
  name = "my_new_key"
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMNybdFBSaM/ccCx3xySx4z2JWMXza1uVj5kw10zX7Gi redix\\gabriel.philippi@TEC98"
}

resource "mgc_virtual_machine_instances" "instances" {
  for_each = var.instances

  name                = each.value.name
  machine_type        = each.value.machine_type
  image               = each.value.image
  ssh_key_name        = mgc_ssh_keys.my_key.name
  allocate_public_ipv4 = each.value.allocate_public_ipv4

  depends_on = [mgc_ssh_keys.my_key]
} 