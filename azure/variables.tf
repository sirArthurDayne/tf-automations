variable "az_region" {
  type        = string
  description = "Region de despliegue de recursos"
  default     = "eastus"
  validation {
    condition     = var.az_region == "eastus" || var.az_region == "eastus2"
    error_message = "[ERROR]: La regiones permitidas son eastus y eastus2"
  }
}

variable "az_vn" {
  type        = string
  description = "rango de red de la virtualNetwork"
  default     = "10.0.0.0/16"
}

variable "az_subnetrange" {
  type        = string
  description = "rango del subnet"
  default     = "10.10.200.0/24"
}

variable "az_project_name" {
  type        = string
  description = "Nombre del proyecto. usado como sufijo"
}

variable "az_enviroment" {
  type        = set(string)
  description = "ambientes del proyecto disponibles. por defecto: 'dev' "
  default     = ["dev"]
}

variable "deploy_tags" {
  type        = map(string)
  description = "etiquetas para asignar al recurso"
  default = {
    environment   = "dev"
    deploy_method = "terraform"
  }
}

variable "myssh_key" {
  type        = string
  description = "llave SSH para pruebas de conexion"
  default     = ""
}



variable "db_name" {
  type        = string
  description = "nombre de la BD"
}

variable "db_username" {
  type        = string
  description = "username de la BD"
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "password de la BD"
  sensitive   = true
}


variable "db_storage_size" {
  type        = number
  description = "size storage in MB."
  validation {
    condition     = var.db_storage_size >= 2048 && var.db_storage_size <= 5120
    error_message = "[ERROR]: db_storaze_size is out of bounds 2048 <= size <= 5120."
  }
}

variable "db_auto_grow_enabled" {
  type        = bool
  description = "enable or disable auto grow feature."
  default     = false
}
