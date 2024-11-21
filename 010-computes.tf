# Create volume for instance boot
resource "openstack_blockstorage_volume_v3" "volume_os" {
  name                 = var.name
  size                 = var.block_device_volume_size
  volume_type          = var.volume_type
  image_id             = var.image_id
  enable_online_resize = true
}

# Create the main network port
resource "openstack_networking_port_v2" "main_port" {
  name               = var.ports[0].name
  network_id         = var.ports[0].network_id
  admin_state_up     = true
  security_group_ids = var.ports[0].security_group_ids
  fixed_ip {
    subnet_id  = var.ports[0].subnet_id
    ip_address = var.ports[0].ip_address
  }
  dynamic "allowed_address_pairs" {
    for_each = var.ports[0].allowed_address_pairs
    content {
      ip_address  = allowed_address_pairs.value.ip_address
      mac_address = allowed_address_pairs.value.mac_address
    }
  }
  port_security_enabled = var.ports[0].port_security
  tags                  = var.ports[0].tags == null ? [] : var.ports[0].tags
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

  # Attach the main port to the instance
  network {
    port = openstack_networking_port_v2.main_port.id
  }

  # Metadata block: combines existing OpenStack metadata with custom metadata
  metadata = { for key, value in var.metadata : key => value if value != null }

  dynamic "scheduler_hints" {
    for_each = var.server_groups
    content {
      group = scheduler_hints.value
    }
  }

  tags = var.tags
}

# Create additional ports if provided
resource "openstack_networking_port_v2" "additional_ports" {
  count = length(var.ports) > 1 ? length(var.ports) - 1 : 0

  name               = var.ports[count.index + 1].name
  network_id         = var.ports[count.index + 1].network_id
  admin_state_up     = true
  security_group_ids = var.ports[count.index + 1].security_group_ids
  fixed_ip {
    subnet_id  = var.ports[count.index + 1].subnet_id
    ip_address = var.ports[count.index + 1].ip_address
  }
  dynamic "allowed_address_pairs" {
    for_each = var.ports[count.index + 1].allowed_address_pairs
    content {
      ip_address  = allowed_address_pairs.value.ip_address
      mac_address = allowed_address_pairs.value.mac_address
    }
  }
  port_security_enabled = var.ports[count.index + 1].port_security
  tags                  = var.ports[count.index + 1].tags == null ? [] : var.ports[count.index + 1].tags
}

# Attach additional ports to the instance
resource "openstack_compute_interface_attach_v2" "attached_ports" {
  count       = length(var.ports) > 1 ? length(var.ports) - 1 : 0
  instance_id = openstack_compute_instance_v2.instance.id
  port_id     = openstack_networking_port_v2.additional_ports[count.index].id
}

# Create floating IP
resource "openstack_networking_floatingip_v2" "ip" {
  count = var.public_ip_network == null ? 0 : 1

  pool = var.public_ip_network
}

# Attach floating IP to the first additional port
resource "openstack_networking_floatingip_associate_v2" "ipa" {
  count       = var.public_ip_network == null ? 0 : 1
  floating_ip = openstack_networking_floatingip_v2.ip[count.index].address
  port_id     = length(openstack_networking_port_v2.additional_ports) > 0 ? openstack_networking_port_v2.additional_ports[0].id : null
}