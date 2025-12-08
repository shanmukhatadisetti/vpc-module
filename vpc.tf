resource "aws_vpc" "main" {
  cidr_block       = var.cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge(
    local.tags,
    {
        Name = "${var.project}-${var.env}-vpc"
    }
  )
}

#Internet GateWay
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.tags,
    {
        Name = "${var.project}-${var.env}"
    }
  )
}

#public_subnet
resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidr)
    vpc_id     = aws_vpc.main.id
    cidr_block =var.public_subnet_cidr[count.index]
    availability_zone =local.availability_zone[count.index]
    map_public_ip_on_launch = true

    tags = merge(
    var.public_subnet_tags,
    local.tags,
    {
        Name = "${var.project}-${var.env}-public-${local.availability_zone[count.index]}"
    }
  )
}

#private_subnet
resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidr)
    vpc_id     = aws_vpc.main.id
    cidr_block =var.private_subnet_cidr[count.index]
    availability_zone =local.availability_zone[count.index]

    tags = merge(
    var.private_subnet_tags,
    local.tags,
    {
        Name = "${var.project}-${var.env}-private-${local.availability_zone[count.index]}"
    }
  )
}

#DataBase_subnet
resource "aws_subnet" "db" {
    count = length(var.db_subnet_cidr)
    vpc_id     = aws_vpc.main.id
    cidr_block =var.db_subnet_cidr[count.index]
    availability_zone =local.availability_zone[count.index]


    tags = merge(
    var.private_subnet_tags,
    local.tags,
    {
        Name = "${var.project}-${var.env}-db-${local.availability_zone[count.index]}"
    }
  )
}

#Elastic IP
resource "aws_eip" "main" {
  domain   = "vpc"
  tags = merge(
    var.eip_tags,
    local.tags,
    {
        Name = "${var.project}-${var.env}-eip"
    }
  )
}

#NatGateWay
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.nat_tags,
    local.tags,
    {
        Name = "${var.project}-${var.env}-Nat_Gateway"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

#public_route_table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.public_route_table,
    local.tags,
    {
        Name = "${var.project}-${var.env}-public"
    }
  )
}

#private_route_table

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.private_route_table,
    local.tags,
    {
        Name = "${var.project}-${var.env}-private"
    }
  )
}

#db_route_table

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.db_route_table,
    local.tags,
    {
        Name = "${var.project}-${var.env}-db"
    }
  )
}
#route_table_association
resource "aws_route_table_association" "public" {
    count = length(var.public_subnet_cidr)
    subnet_id      = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
    count = length(var.private_subnet_cidr)
    subnet_id      = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db" {
    count = length(var.db_subnet_cidr)
    subnet_id      = aws_subnet.db[count.index].id
    route_table_id = aws_route_table.db.id
}



#routing 
resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route" "db_route" {
  route_table_id            = aws_route_table.db.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

