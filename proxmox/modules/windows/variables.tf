variable "pve_api_endpoint" {
  type        = string
  description = "URL del enpdpoint usado para comunicarse con la API de Proxmox"
  default     = ""
}

variable "pve_api_token" {
  type        = string
  description = "API Token requerido para autenticarse contra Proxmox"
  default     = ""
}

variable "pve_target_node" {
  type        = string
  description = "Nodo principal de Proxmox"
  default     = ""
}


variable "vm_image_url" {
  type        = string
  description = "URL de proveedor de la imagen de la VM. formatos: .img y .qcow2"
  default     = ""
}

variable "windows_image_local" {
  type        = string
  description = "downloaded image path inside proxmox"
  default     = ""
}
