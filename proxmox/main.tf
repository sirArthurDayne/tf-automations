resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.pve_target_node
  url          = var.vm_image_url
}


resource "proxmox_virtual_environment_vm" "vm_cloudimage_demo" {
    name = "corintia-demo"
    description = "test deployment based on cloud_image"
    vm_id = 2000
    node_name = var.pve_target_node
    started = false # start after creation
    tags = ["terraform", "dev" ]


    agent {
      enabled = false #dont qemu agent
    }

 # if agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
  stop_on_destroy = true

    initialization {
      datastore_id = "local-zfs"
      user_account {
        username = "ubuntu"
        password = "calidad18!"
        keys = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]
      }

      ip_config {
        ipv4 {
          address = "dhcp"
        }
      }

      # user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
    }

    network_device {
      bridge = "vmbr0"
    }
    operating_system {
    type = "l26"
  }

  memory {
    dedicated = 1024
  }

    disk {
      datastore_id = "local-zfs"
      # file_format = "qcow2"
      file_id = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
      interface = "virtio0"
      iothread = true
      discard = "on"
      size = 10
    }

    serial_device {}
}

resource "tls_private_key" "ubuntu_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "ubuntu_vm_private_key" {
  value     = tls_private_key.ubuntu_vm_key.private_key_pem
  sensitive = true
}

output "ubuntu_vm_public_key" {
  value = tls_private_key.ubuntu_vm_key.public_key_openssh
}
