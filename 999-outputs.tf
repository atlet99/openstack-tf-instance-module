# Output for instance IDs as a flat list
output "instance_ids" {
  value       = [openstack_compute_instance_v2.instance.id]
  description = "Flat list of instance IDs."
}

# Output for private IPs as a flat list
output "private_ips" {
  value = concat(
    [openstack_networking_port_v2.main_port.fixed_ip[0].ip_address],
    [for port in openstack_networking_port_v2.additional_ports : port.fixed_ip[0].ip_address]
  )
  description = "Flat list of private IP addresses for all ports (main and additional)."
}

# Output for floating IPs as a flat list
output "floating_ips" {
  value       = length(openstack_networking_floatingip_v2.ip) > 0 ? openstack_networking_floatingip_v2.ip[*].address : []
  description = "Flat list of floating IP addresses, if any."
}

# Output for ports with details as a flat list
output "instance_info" {
  value = concat(
    [
      {
        id         = openstack_networking_port_v2.main_port.id
        name       = openstack_networking_port_v2.main_port.name
        tags       = openstack_networking_port_v2.main_port.tags
        private_ip = openstack_networking_port_v2.main_port.fixed_ip[0].ip_address
      }
    ],
    [
      for port in length(openstack_networking_port_v2.additional_ports) > 0 ? openstack_networking_port_v2.additional_ports : [] : {
        id         = port.id
        name       = port.name
        tags       = port.tags
        private_ip = port.fixed_ip[0].ip_address
      }
    ]
  )
  description = "Flat list of ports with tags, names, and private IPs for the instance."
}

# Output for the primary port details
output "primary_port" {
  value = {
    id         = openstack_networking_port_v2.main_port.id
    name       = openstack_networking_port_v2.main_port.name
    private_ip = openstack_networking_port_v2.main_port.fixed_ip[0].ip_address
  }
  description = "Details of the primary port attached to the instance."
}

# Output for additional ports
output "additional_ports" {
  value = [
    for port in openstack_networking_port_v2.additional_ports : {
      id         = port.id
      name       = port.name
      private_ip = port.fixed_ip[0].ip_address
    }
  ]
  description = "Details of additional ports attached to the instance."
}

# Output for attached floating IPs
output "attached_floating_ips" {
  value       = [for assoc in openstack_networking_floatingip_associate_v2.ipa : assoc.floating_ip]
  description = "List of floating IPs attached to additional ports."
}
