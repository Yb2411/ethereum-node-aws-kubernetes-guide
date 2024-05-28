resource "aws_vpc" "eks" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "eks" {
  count = 2

  vpc_id                  = aws_vpc.eks.id
  cidr_block              = cidrsubnet(aws_vpc.eks.cidr_block, 8, count.index)
  availability_zone       = element(["eu-west-3a", "eu-west-3b"], count.index)
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "eks" {
  vpc_id = aws_vpc.eks.id
}

resource "aws_route_table" "eks" {
  vpc_id = aws_vpc.eks.id
}

resource "aws_route" "eks" {
  route_table_id         = aws_route_table.eks.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks.id
}

resource "aws_route_table_association" "eks" {
  count          = 2
  subnet_id      = element(aws_subnet.eks[*].id, count.index)
  route_table_id = aws_route_table.eks.id
}

output "vpc_id" {
  value = aws_vpc.eks.id
}

output "subnet_ids" {
  value = aws_subnet.eks[*].id
}
