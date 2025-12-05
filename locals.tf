locals {
  tags = {
    project = var.project
    env = var.env
    terraform = true
  }

  availability_zone = slice(data.aws_availability_zones.available.names,0,2)
}