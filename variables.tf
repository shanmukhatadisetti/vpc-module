variable "cidr" {
    default = "10.0.0.0/16"
  
}

variable "project" {
    type = string
  
}

variable "env" {
    type = string
  
}

variable "public_subnet_cidr" {
    type = list(string)
  
}

variable "public_subnet_tags" {
    type = map(string)
    default = {}
  
}

variable "private_subnet_cidr" {
    type = list(string)
  
}

variable "private_subnet_tags" {
    type = map(string)
    default = {}
  
}

variable "db_subnet_cidr" {
    type = list(string)
  
}

variable "db_subnet_tags" {
    type = map(string)
    default = {}
  
}
variable "eip_tags" {
    type = map(string)
    default = {}  
}

variable "nat_tags" {
    type = map(string)
    default = {}
  
}

variable "public_route_table" {
    type = map(string)
    default = {}
  
}

variable "private_route_table" {
    type = map(string)
    default = {}
  
}

variable "db_route_table" {
    type = map(string)
    default = {}
  
}

variable "is_peering_required" {
    default = false
  
}

variable "peering_tags" {
    type = map(string)
    default = {}
  
}