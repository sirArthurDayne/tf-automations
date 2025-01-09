# Deploy Templates by modules

module "ubuntu" {
    source = "./modules/ubuntu"
    pve_api_endpoint = var.pve_api_endpoint
    pve_api_token = var.pve_api_token
    pve_target_node = var.pve_target_node
    vm_image_local = var.vm_image_local
    vm_image_url = var.vm_image_url
    vm_user = var.vm_user
    vm_passwd = var.vm_passwd
    vm_ssh_key = var.vm_ssh_key
}

module "windows" {
    source = "./modules/windows"
    pve_api_endpoint = var.pve_api_endpoint
    pve_api_token = var.pve_api_token
    pve_target_node = var.pve_target_node
    windows_image_local = var.windows_local_image
    vm_image_url = var.vm_image_url
}
