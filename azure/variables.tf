variable "az_region" {
  type        = string
  description = "Region de despliegue de recursos"
  default     = "eatus"
}

variable "az_vn" {
  type        = string
  description = "rango de red de la virtualNetwork"
  default     = "10.0.0.0/16"
}

variable "az_project_name" {
  type        = string
  description = "Nombre del proyecto. usado como sufijo"
}

variable "az_enviroment" {
  type        = string
  description = "ambiente del proyecto"
  default     = "dev"
}

variable "deploy_tags" {
  type        = map(string)
  description = "etiquetas para asignar al recurso"
  default = {
    environment = "dev"
    deploy_method ="terraform"
  }
}

variable "myssh_key" {
    type = string
    description = "llave SSH para pruebas de conexion"
    default = ""
}
