locals {
  subnet_cidr_blocks = distinct(var.public_subnet_cidr_list)
}

locals {
  resource_name = "cloud"
}
