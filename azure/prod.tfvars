az_region       = "eastus"
az_vn           = "172.16.0.0/16"
az_subnetrange  = "172.16.50.0/24"
az_project_name = "blastwave-lab"
az_enviroment   = ["dev", "prod", "qa"]
deploy_tags = {
  deploy_method = "terraform"
}
myssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxk4wESIqsWtvx81f1ybxmBvIdp8WkZvkxLTOOlsnLMXByvGQFY29t0jHWEM5OwIPJShNhO8qNBOZ2DTw4KCwulg0Xf7mAXJkBPLE1b0v8M/yd9tQEpXJr/is6jAZGp7SVJ/Vp66FVDpqwtHGM/T8z1OYWbNKtVQHLhM+EoAp0AXT/ZOJhtyLznhmXjhK3xoY1CTK9OfVKBvOsG7who2GS50X4pBeDudAA8X7bNLtgQLnismxGbqAudckNXkJtneFv5KVfBlQdqE1QShVMKhrQZkeItUZpakJottqrfhnYreH9iapHF2P8gdB8F3OVgti/d1dewlGbtndTof+Hj8pz ubuntu@linuxvm"

db_name              = "blackhole"
db_username          = "krosisadm"
db_password          = "hashicorp123!"
db_storage_size      = 5120
db_auto_grow_enabled = true
