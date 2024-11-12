output "instance" {
  value = openstack_compute_instance_v2.instance
}

output "ip" {
  value = openstack_networking_floatingip_v2.ip[*].address
}

output "all_metadata" {
  value = openstack_compute_instance_v2.instance.metadata
}

output "instance_info" {
  value = [
    for i, index in openstack_compute_instance_v2.instance : {
      id          = i.id
      name        = i.name
      ports       = [
        for p in openstack_networking_port_v2.port : {
          id   = p.id
          name = p.name
          tags = p.tags
        } if p.id != null
      ]
      floating_ip = length(openstack_networking_floatingip_v2.ip) > index ? openstack_networking_floatingip_v2.ip[index].address : null
    }
  ]
  description = "Detailed information for each instance, including port tags and floating IPs."
}