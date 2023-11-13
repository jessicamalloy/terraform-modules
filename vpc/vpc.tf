/*
 * VPC with a range of 1 (public) to 6 subnets (3 public, 3 private) 
 * across 3 Availability Zones.
 */

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-VPC"
    ProjectName = var.project_name
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-IG"
    ProjectName = var.project_name
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.project_name}-public-subnet-a"
    ProjectName = var.project_name
  }
}

resource "aws_subnet" "public_subnet_b" {
  count = local.build_public_b
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.20.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.project_name}-public-subnet-b"
    ProjectName = var.project_name
  }
}

resource "aws_subnet" "public_subnet_c" {
  count = local.build_public_c
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.30.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "${var.project_name}-public-subnet-c"
    ProjectName = var.project_name
  }
}

resource "aws_subnet" "private_subnet_a" {
  count = local.build_private_a
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.5.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.project_name}-private-subnet-a"
    ProjectName = var.project_name
  }
}

resource "aws_subnet" "private_subnet_b" {
  count = local.build_private_b
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.60.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.project_name}-private-subnet-b"
    ProjectName = var.project_name
  }
}

resource "aws_subnet" "private_subnet_c" {
  count = local.build_private_c
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.70.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "${var.project_name}-private-subnet-c"
    ProjectName = var.project_name
  }
}

resource "aws_eip" "private_a" {
  count      = local.build_elastic_a
  vpc        = true
  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "${var.project_name}-private-eip-a"
    ProjectName = var.project_name
  }
}

resource "aws_eip" "private_b" {
  count      = local.build_elastic_b
  vpc        = true
  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "${var.project_name}-private-eip-b"
    ProjectName = var.project_name
  }
}

resource "aws_eip" "private_c" {
  count      = local.build_elastic_c
  vpc        = true
  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "${var.project_name}-private-eip-c"
    ProjectName = var.project_name
  }
}

resource "aws_nat_gateway" "nat_gateway_a" {
  count         = local.build_private_a
  allocation_id = var.create_private_eip ? aws_eip.private_a[count.index].id : null
  subnet_id     = aws_subnet.public_subnet_a.id
  depends_on    = [aws_internet_gateway.gw]

  tags = {
    Name = "${var.project_name}-nat-a"
    ProjectName = var.project_name
  }
}

resource "aws_nat_gateway" "nat_gateway_b" {
  count         = local.build_private_b
  allocation_id = var.create_private_eip ? aws_eip.private_b[count.index].id : null
  subnet_id     = aws_subnet.public_subnet_b[count.index].id
  depends_on    = [aws_internet_gateway.gw]

  tags = {
    Name = "${var.project_name}-nat-b"
    ProjectName = var.project_name
  }
}

resource "aws_nat_gateway" "nat_gateway_c" {
  count         = local.build_private_c
  allocation_id = var.create_private_eip ? aws_eip.private_c[count.index].id : null
  subnet_id     = aws_subnet.public_subnet_c[count.index].id
  depends_on    = [aws_internet_gateway.gw]

  tags = {
    Name = "${var.project_name}-nat-c"
    ProjectName = var.project_name
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  depends_on = [aws_internet_gateway.gw]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.project_name}-public-route-table"
    ProjectName = var.project_name
  }
}

resource "aws_route_table" "private_route_table_a" {
  count = local.build_private_a
  vpc_id = aws_vpc.vpc.id

  route {
    nat_gateway_id = aws_nat_gateway.nat_gateway_a[count.index].id 
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "${var.project_name}-private-route-table-a"
    ProjectName = var.project_name
  }
}

resource "aws_route_table" "private_route_table_b" {
  count = local.build_private_b
  vpc_id = aws_vpc.vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat_gateway_b[count.index].id
  }

  tags = {
    Name = "${var.project_name}-private-route-table-b"
    ProjectName = var.project_name
  }
}

resource "aws_route_table" "private_route_table_c" {
  count = local.build_private_c
  vpc_id = aws_vpc.vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat_gateway_c[count.index].id
  }

  tags = {
    Name = "${var.project_name}-private-route-table-c"
    ProjectName = var.project_name
  }
}

resource "aws_route_table_association" "ra_public_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "ra_public_b" {
  count = local.build_public_b
  subnet_id      = aws_subnet.public_subnet_b[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "ra_public_c" {
  count = local.build_public_c
  subnet_id      = aws_subnet.public_subnet_c[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "ra_private_a" {
  count = local.build_private_a
  subnet_id      = aws_subnet.private_subnet_a[count.index].id
  route_table_id = aws_route_table.private_route_table_a[count.index].id
}

resource "aws_route_table_association" "ra_private_b" {
  count = local.build_private_b
  subnet_id      = aws_subnet.private_subnet_b[count.index].id
  route_table_id = aws_route_table.private_route_table_b[count.index].id
}

resource "aws_route_table_association" "ra_private_c" {
  count = local.build_private_c
  subnet_id      = aws_subnet.private_subnet_c[count.index].id
  route_table_id = aws_route_table.private_route_table_c[count.index].id
}

resource "aws_network_acl" "network_acl" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = local.public_subnets

  ingress {
      protocol   = "-1"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
  }
  egress {
      protocol   = "-1"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
  }

  tags = {
    Name = "${var.project_name}-nacl"
    ProjectName = var.project_name
  }
}

# VPC id added in Parameter Store to be consumed by Tasks if needed

resource "aws_ssm_parameter" "ecs_service_vpc_id" {
  name  = "/${var.project_name}/ecs_service_vpc_id"
  type  = "String"
  value = aws_vpc.vpc.id
}

resource "aws_ssm_parameter" "ecs_service_public_subnet_ids" {
  name  = "/${var.project_name}/ecs_service_public_subnet_ids"
  type  = "String"
  value = join(", ", local.public_subnets) 
}

resource "aws_ssm_parameter" "ecs_service_private_subnet_ids" {
  name  = "/${var.project_name}/ecs_service_private_subnet_ids"
  type  = "String"
  value = join(", ", local.private_subnets) 
}
