
# Ubuntu server template
resource "proxmox_virtual_environment_vm" "ubuntu_template" {
  name        = "ubuntu-template"
  description = "ubuntu 2204 template for k3s and k8s deployments"
  vm_id       = 5000
  node_name   = var.pve_target_node
  template    = true
  started     = false # start after creation
  tags        = ["terraform", "template"]
  agent {
    enabled = false #dont qemu agent
  }
  # if agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
  stop_on_destroy = true
  # CPU & motherboard
  bios          = "seabios"
  scsi_hardware = "virtio-scsi-pci"
  cpu {
    architecture = "x86_64"
    cores        = 2
    type         = "host"
  }
  operating_system {
    type = "l26"
  }
  #RAM
  memory {
    dedicated = 2048
    floating  = 0
  }
  #network interface
  network_device {
    enabled = true
    bridge  = "vmbr0"
    model   = "virtio"
  }
  disk {
    datastore_id = "local-zfs"
    file_id      = var.vm_image_local
    file_format  = "qcow2"
    interface    = "scsi0"
    iothread     = false
    discard      = "ignore"
    size         = 10   #Gigabytes
    ssd          = true #ssd emulation
  }
  # cloudinit setup
  initialization {
    datastore_id = "local-zfs"
    user_account {
      username = var.vm_user
      password = var.vm_passwd
      keys     = [var.vm_ssh_key]
    }
    # change ip after cloning this resource
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
  # video signal
  vga {
    type = "serial0" #allows for connectivity even without network access
  }
  #serial
  serial_device {
    device = "socket"
  }
}
