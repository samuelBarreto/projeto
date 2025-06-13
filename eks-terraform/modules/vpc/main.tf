resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = merge({
    Name = "eks-vpc-${var.environment}"
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
    Name = "eks-public-${var.environment}-${count.index}"
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
      Name = "eks-public-rt-${var.environment}"
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
      Name = "eks-private-${var.environment}-${count.index}"
    },
    var.tags
  )
}

# EIP para o NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    {
      Name = "eks-nat-eip-${var.environment}"
    },
    var.tags
  )
}

# NAT Gateway em uma subnet pública (usando a primeira subnet pública)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    {
      Name = "eks-nat-gateway-${var.environment}"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.igw]
}

# Route table para subnets privadas
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(
    {
      Name = "eks-private-rt-${var.environment}"
    },
    var.tags
  )
}

# Associação das subnets privadas à route table privada
resource "aws_route_table_association" "private_association" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# Security Group for public subnets
resource "aws_security_group" "public_sg" {
  name        = "eks-public-sg-${var.environment}"
  description = "Security group for public subnet resources"
  vpc_id      = aws_vpc.main.id

  # Exemplo: liberar SSH e HTTP para acesso externo
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "eks-public-sg-${var.environment}"
    },
    var.tags
  )
}

# Security Group for private subnets
resource "aws_security_group" "private_sg" {
  name        = "eks-private-sg-${var.environment}"
  description = "Security group for private subnet resources"
  vpc_id      = aws_vpc.main.id

  # Exemplo: liberar apenas saída para internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "eks-private-sg-${var.environment}"
    },
    var.tags
  )
}