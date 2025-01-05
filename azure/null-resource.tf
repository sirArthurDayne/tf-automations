resource "time_sleep" "wait_and_provision" {
  depends_on      = [azurerm_linux_virtual_machine.linuxvm]
  create_duration = "10s"

}

# resource "null_resource" "sync_app1_static" {
#   depends_on = [time_sleep.wait_and_provision]
#   for_each   = var.az_enviroment
#   connection {
#     type        = "ssh"
#     host        = azurerm_linux_virtual_machine.linuxvm[each.key].public_ip_address
#     user        = azurerm_linux_virtual_machine.linuxvm[each.key].admin_username
#     private_key = file("~/.ssh/tf-tests")
#   }
#   provisioner "file" {
#     source      = "./dependencies/apache.txt"
#     destination = "/tmp/apache.txt"
#     # on_failure = continue
#   }
#   provisioner "remote-exec" {
#     inline = ["sudo cp /tmp/apache.txt /var/www/html/apache.txt"]
#   }
# }
