variable "AZ_location" {
  type = string
  description = "Localizacao da zona de disponibilidade A"
}

variable "AZ2_location" {
  type = string
  description = "Localizacao da zona de disponibilidade B"
}

variable "region" {
  type = string
  description = "Localizacao da regiao"
}

variable "keypair01" {
  type = string
  description = "keypair para acesso VM"
}