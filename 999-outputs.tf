# Output for instance IDs as a flat list
output "instance_ids" {
  value = [openstack_compute_instance_v2.instance.id]
  description = "Flat list of instance IDs."
}

# Output for private IPs as a flat list
output "private_ips" {
  value = [for port in openstack_networking_port_v2.port : port.fixed_ip[0].ip_address]
  description = "Flat list of private IP addresses for each port."
}

# Output for floating IPs as a flat list
output "floating_ips" {
  value = length(openstack_networking_floatingip_v2.ip) > 0 ? openstack_networking_floatingip_v2.ip[*].address : []
  description = "Flat list of floating IP addresses, if any."
}

# Output for ports with details as a flat list
output "instance_info" {
  value = [
    for port in openstack_networking_port_v2.port : {
      id         = port.id
      name       = port.name
      tags       = port.tags
      private_ip = port.fixed_ip[0].ip_address
    }
  ]
  description = "Flat list of ports with tags, names, and private IPs for the instance."
}