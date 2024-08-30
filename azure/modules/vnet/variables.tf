variable "vnet_name" {
  type        = string
  description = "nombre del vnet"
}

variable "vnet_address_space" {
    type = list(string)
    description ="espacio de la subnet .defautlt = [172.16.0.0/16] "
default = ["172.16.0.0/16"]
}

variable "vnet_rg_name" {
    type = string
    description = "nombre del rg"
}
variable "vnet_rg_location" {
    type = string
    description = "ubicacion del rg"
}

variable "vnet_tags" {
    type = map(string)
    description = "vnet tags"
    default = {}
}
