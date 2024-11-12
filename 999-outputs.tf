output "instance" {
  value = openstack_compute_instance_v2.instance
}

output "ip" {
  value = openstack_networking_floatingip_v2.ip[*].address
}

output "all_metadata" {
  value = openstack_compute_instance_v2.instance.metadata
}

output "floating_ip" {
  value = openstack_networking_floatingip_v2.ip[*].address
}

output "instance_info" {
  value = [
    for instance in flatten([openstack_compute_instance_v2.instance]) : {
      id          = instance.id
      name        = instance.name
      ports       = [
        for port in openstack_networking_port_v2.port : {
          id   = port.id
          name = port.name
          tags = port.tags
        } if port.id != null
      ]
    }
  ]
  description = "Detailed information for each instance, including port tags."
}
