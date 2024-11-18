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
    allowed_address_pairs = optional(list(object({
      ip_address  = string
      mac_address = optional(string)
    })), [])
    tags = optional(list(string))
  }))
  default = [
    {
      name                  = ""
      network_id            = ""
      subnet_id             = ""
      admin_state_up        = true
      security_group_ids    = []
      ip_address            = null
      port_security         = true
      allowed_address_pairs = []
      tags                  = []
    }
  ]
  description = "The ports list, at least 1 port is required"
}

variable "block_device_volume_size" {
  type        = number
  description = <<EOF
The volume size of block device
EOF
  default     = 20
}

variable "block_device_delete_on_termination" {
  type        = bool
  description = <<EOF
Delete block device when instance is shut down
EOF
  default     = true
}

variable "volume_type" {
  type        = string
  description = "The type of volume to use, e.g., 'ceph-ssd', 'kz-ala-1-san-nvme-h1' or 'ceph-hdd'"
  default     = "ceph-ssd"
}

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

# Added all information about metadata;

variable "metadata" {
  type        = map(string)
  description = <<-EOF
  Metadata for the OpenStack instance, used for categorization and identification of the service across environments and projects:
  - environment: Specifies the deployment environment (e.g., "dev", "staging", "prod", "infra") to indicate where the instance is used.
  - project: Defines the project name or identifier associated with this instance (e.g., "tesla"), useful for organizing and filtering resources within larger environments.
  - service_type: Describes the type of service provided by this instance (e.g., "runner", "database", "web"), helping to classify the role of the instance in the architecture.
  - service_name: A unique name for the specific service this instance runs (e.g., "tesla_runner_infra"), enabling more granular tracking and management of resources.
  - service_role: Defines the role of the instance within the service (e.g., "master", "worker", "backup"), useful for distributed or clustered services with distinct roles.
  These metadata fields allow for more effective resource organization, monitoring, and automated management within OpenStack and other third-party integrations.
  EOF
  default = {
    environment  = null
    project      = null
    service_type = null
    service_name = null
    service_role = null
  }
}

# Variable for designating the primary port index
variable "primary_port_index" {
  type        = number
  description = <<EOF
The index of the primary port in the 'ports' list. Default is 0 (the first port).
EOF
  default     = 0
}

# Variable to enable floating IP assignment for additional ports
variable "attach_floating_ip" {
  type        = bool
  description = "Flag to indicate if floating IPs should be attached to the additional ports."
  default     = true
}
