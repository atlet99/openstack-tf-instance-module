output "instance" {
  value = openstack_compute_instance_v2.instance
}

output "ip" {
  value = openstack_networking_floatingip_v2.ip[*].address
}

output "all_metadata" {
  value = openstack_compute_instance_v2.instance.metadata
}
