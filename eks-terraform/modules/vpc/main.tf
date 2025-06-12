resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = merge({
    Name = "eks-vpc"
  }, var.tags
  )
}

# Subnets Públicas
resource "aws_subnet" "public" {
  count = 3

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index + 10)
  availability_zone = "${var.region}${element(["a", "b", "c"], count.index)}"
  map_public_ip_on_launch = true

  tags = merge (
    {
    Name = "eks-public-${count.index}"
    },
     var.tags
  )

}

# Internet Gateway (necessário para subnets públicas)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    {
      Name = "eks-igw"
    },
    var.tags
  )
}

# Route table para subnets públicas
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge (
    {
      Name = "eks-public-rt"
    },
    var.tags
  )
}

# Associação das subnets públicas à route table
resource "aws_route_table_association" "public_association" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Subnets Privadas
resource "aws_subnet" "private" {
  count = 3

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index + 1)
  availability_zone = "${var.region}${element(["a", "b", "c"], count.index)}"

  tags = merge (
    {
      Name = "eks-private-${count.index}"
    },
    var.tags
  )
}
# Route table para subnets privadas
