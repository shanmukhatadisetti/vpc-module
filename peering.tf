resource "aws_vpc_peering_connection" "main" {
  count = var.is_peering_required == true ? 1 : 0
  peer_vpc_id   = data.aws_vpc.default.id
  vpc_id        = aws_vpc.main.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
  auto_accept = true
  tags = merge(
    var.peering_tags,
    local.tags,
    {
        Name = "${var.project}-${var.env}-default"
    }
  )
}

#peering routing 
resource "aws_route" "public" {
    count = var.is_peering_required == true ? 1 : 0
    route_table_id            = aws_route_table.public.id
    destination_cidr_block    = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.main[count.index].id
}

resource "aws_route" "private" {
    count = var.is_peering_required == true ? 1 : 0
    route_table_id            = aws_route_table.private.id
    destination_cidr_block    = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.main[count.index].id
}

resource "aws_route" "db" {
    count = var.is_peering_required == true ? 1 : 0
    route_table_id            = aws_route_table.db.id
    destination_cidr_block    = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.main[count.index].id
}

resource "aws_route" "default_vpc_route" {
    count = var.is_peering_required == true ? 1 : 0
    route_table_id            = data.aws_route_table.main.id
    destination_cidr_block    = var.cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.main[count.index].id
}

