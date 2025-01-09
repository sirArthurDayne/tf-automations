terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.66.2"
    }
  }
}

provider "proxmox" {
  # Configuration options
  endpoint=var.pve_api_endpoint
  api_token=var.pve_api_token
  insecure = true #selfcert = true
  ssh {
      agent = true
      # username = ""
      # password = ""
  }
  alias = "proxmox"
}

