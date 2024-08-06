terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.61.1"
    }
  }
}

provider "proxmox" {
  # Configuration options
  endpoint=""
  api_token=""
  insecure = true #selfcert = true
  ssh {
  }
}

