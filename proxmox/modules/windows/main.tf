# Windows Server template
resource "proxmox_virtual_environment_vm" "windows_template" {
  name        = "windows-template"
  description = "Windows Server 2022 template for AD deployments"
  vm_id       = 5001
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
  bios          = "ovmf"
  scsi_hardware = "virtio-scsi-pci"
  cpu {
    architecture = "x86_64"
    cores        = 2
    type         = "host"
  }
   machine  = "q35"
  operating_system {
    type = "win11"
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
  efi_disk {
        datastore_id = "local-zfs"
        type = "4m"
        file_format = "iso"
        pre_enrolled_keys = 1
    }
    tpm_state {
        datastore_id = "local-zfs"
        version = "v2.0"
    }
  disk {
    datastore_id = "local-zfs"
    file_id      = var.windows_image_local
    file_format  = "qcow2"
    interface    = "scsi0"
    iothread     = false
    discard      = "ignore"
    size         = 40   #Gigabytes
    ssd          = true #ssd emulation
  }
  disk {
    datastore_id = "local-zfs"
    file_id      = "local:iso/virtio-win-0.1.262.iso"
    file_format  = "qcow2"
    interface    = "scsi0"
    iothread     = false
    discard      = "ignore"
    size         = 40   #Gigabytes
    ssd          = true #ssd emulation
  }
  # video signal
  vga {
    type = "std"
  }
  #serial
  serial_device {
    device = "socket"
  }
}
