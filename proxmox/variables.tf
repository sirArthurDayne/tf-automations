variable "pve_api_endpoint" {
    type = string
    description = "URL del enpdpoint usado para comunicarse con la API de Proxmox"
    default="https://10.10.0.110:8006/"
}

variable "pve_api_token" {
    type = string
    description = "API Token requerido para autenticarse contra Proxmox"
    default="terraform@pve!terraform=e6d4d9d2-4f53-4ad2-beb4-da593ce2ef47"
}

variable "pve_target_node" {
    type = string
    description = "Nodo principal de Proxmox"
    default="citadel"
}

variable "vm_ssh_key" {
    description = "llave SSH de conexion contra las VMs"
    default="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHTOuTHR+Dh+dMdPkpmE1NkbUBnqgun+9aOA9lhQ/5ET terraform-dev-ssh"
}

variable "vm_image_url" {
    type = string
    description = "URL de proveedor de la imagen de la VM. formatos: .img y .qcow2"
    default="https://cloud-images.ubuntu.com/oracular/20240611/oracular-server-cloudimg-amd64.img"
}
