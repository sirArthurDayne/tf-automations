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

