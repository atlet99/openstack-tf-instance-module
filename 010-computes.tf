# Create volume for instance boot
resource "openstack_blockstorage_volume_v3" "volume_os" {
  name                 = var.name
  size                 = var.block_device_volume_size
  volume_type          = "ceph-ssd"
  image_id             = var.image_id
  enable_online_resize = true
}

# Create instance
resource "openstack_compute_instance_v2" "instance" {
  name        = var.name
  flavor_name = var.flavor_name

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.volume_os.id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = var.block_device_delete_on_termination
  }

  key_pair = var.key_pair_name

  config_drive = true
  user_data    = var.user_data

  dynamic "scheduler_hints" {
    for_each = var.server_groups
    content {
      group = scheduler_hints.value
    }
  }

  dynamic "network" {
    for_each = var.ports

    content {
      port = openstack_networking_port_v2.port[network.key].id
    }
  }

  tags = var.tags
}

# Create network port
resource "openstack_networking_port_v2" "port" {
  count = length(var.ports)

  name               = var.ports[count.index].name
  network_id         = var.ports[count.index].network_id
  admin_state_up     = var.ports[count.index].admin_state_up == null ? true : var.ports[count.index].admin_state_up
  security_group_ids = var.ports[count.index].security_group_ids == null ? [] : var.ports[count.index].security_group_ids
  fixed_ip {
    subnet_id  = var.ports[count.index].subnet_id
    ip_address = var.ports[count.index].ip_address == null ? null : var.ports[count.index].ip_address
  }
  port_security_enabled = var.ports[count.index].port_security

  dynamic "allowed_address_pairs" {
    for_each = var.ports[count.index].allowed_address_pairs
    content {
      ip_address = allowed_address_pairs.value
    }
  }
}

# Create floating IP
resource "openstack_networking_floatingip_v2" "ip" {
  count = var.public_ip_network == null ? 0 : 1

  pool = var.public_ip_network
}

# Attach floating IP to port
resource "openstack_networking_floatingip_associate_v2" "ipa" {
  count = var.public_ip_network == null ? 0 : 1

  floating_ip = openstack_networking_floatingip_v2.ip[count.index].address
  port_id     = openstack_networking_port_v2.port[count.index].id
}
