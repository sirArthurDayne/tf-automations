data "azurerm_subscription" "current_subscription" {}

output "rg_URL" {
  description = "URL del grupo de recursos"
  value       = "https://portal.azure.com/#@${data.azurerm_subscription.current_subscription.tenant_id}/resource${azurerm_resource_group.rg.id}"
}

# iterador y objeto: salida
# output "publicIP_two_input" {
#   description = "String de conexion SSH por ambiente"
#   value = [for env, ip in azurerm_public_ip.publicip: "[${env}]: ssh ubuntu@${ip.ip_address}" ]
# }

# mapear salida a un map
output "sshconn" {
  description = "String de conexion SSH por ambiente"
  value = {for env, ip in azurerm_public_ip.publicip: env => "ssh ubuntu@${ip.ip_address}" }
  sensitive = true
}

# show only keys
output "sshconnKeys" {
  description = "Show map keys only"
  value = keys({for env, ip in azurerm_public_ip.publicip: env => "ssh ubuntu@${ip.ip_address}" })
}

#show only values
output "sshconnValues" {
  description = "Show map values only"
  value = values({for env, ip in azurerm_public_ip.publicip: env => "ssh ubuntu@${ip.ip_address}" })
}

