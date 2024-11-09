# Terraform Openstack Instances

_This project aims to create a module to deploy instance(s) on openstack provider._

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/atlet99/openstack-tf-instance-module)

**Note:** This module requires **Terraform version 1.5.0** or higher and **OpenStack provider version 3.0.0** or higher.

## Usage examples

```terraform
module "test_instance_simple" {
	source  = "github.com/atlet99/openstack-tf-instance-module"
	version = "v1.0.0"
 
	name = "instance"
	flavor_name = "m1.xs" 
	image_id = "<image_id>"
	key_pair_name = "my_key_pair"
	public_ip_network = "floating"

	ports = [
		{
			name = "db_port",
			network_id = "db_network_id",
			subnet_id = "db_subnet_id",
		},
		{
			name = "web_port",
			network_id = "web_network_id",
			subnet_id = "web_subnet_id",
		}
	]
	server_groups = ["web"]
}
```