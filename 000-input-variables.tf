variable "key_pair_name" {
  type        = string
  description = <<EOF
The name of the ssh key referenced in openstack
EOF
}

variable "user_data" {
  type        = string
  default     = null
  description = "The user data for instance"
}

variable "image_id" {
  type = string

  description = <<EOF
The image's id referenced in openstack
EOF
}

variable "name" {
  type        = string
  description = <<EOF
Instance's name
EOF
}

variable "flavor_name" {
  type        = string
  description = <<EOF
Instance's flavor name referenced in openstack
EOF
}

variable "public_ip_network" {
  type        = string
  description = <<EOF
The name of the network who give floating IPs
EOF
  default     = null
}

variable "ports" {
  type = list(object({
    name               = string
    network_id         = string
    subnet_id          = string
    admin_state_up     = optional(bool)
    security_group_ids = optional(list(string))
    ip_address         = optional(string)
    port_security      = optional(bool)
    allowed_address    = optional(list(string))
  }))
  default = [
    {
      name          = ""
      network_id    = ""
      subnet_id     = ""
      port_security = true
    }
  ]
  description = <<EOF
The ports list, at least 1 port is required
EOF
}

variable "allowed_addresses" {
  type        = list(string)
  description = <<EOF
Allowed addresses on ports
EOF
  default     = []
}

variable "block_device_volume_size" {
  type        = number
  description = <<EOF
The volume size of block device
EOF
  default     = 20
}

variable "block_volume_type" {
  type        = string
  description = <<EOF
Instance's block volume type
EOF
  default     = ""
}

variable "block_device_delete_on_termination" {
  type        = bool
  description = <<EOF
Delete block device when instance is shut down
EOF
  default     = true
}

# variable "port_security" {
#   type = bool
#   description = <<EOF
# Whether to explicitly enable or disable port security on the port.
# In order to disable port security, the port must not have any security groups.
# EOF
#   default = true
# }

variable "server_groups" {
  type        = list(string)
  description = <<EOF
List of server group id
EOF
  default     = []
}

variable "tags" {
  type        = list(string)
  default     = null
  description = "The instances tags"
}
