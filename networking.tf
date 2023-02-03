# NETWORKING
# >>> VPC
resource "aws_vpc" "microservices-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "microservices-vpc"
  }
}
# <<< 

# >>> MAIN SUBNETS
resource "aws_subnet" "microservices-subnet-1" {
  vpc_id            = aws_vpc.microservices-vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "microservices-subnet-1"
  }
}

resource "aws_subnet" "microservices-subnet-2" {
  vpc_id            = aws_vpc.microservices-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2b"
  tags = {
    Name = "microservices-subnet-2"
  }
}

resource "aws_subnet" "microservices-subnet-3" {
  vpc_id            = aws_vpc.microservices-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2c"
  tags = {
    Name = "microservices-subnet-3"
  }
}
# <<<

# >>> VPC SUBNET GROUP
resource "aws_db_subnet_group" "microservices-subnet-group" {
  name = "microservices-subnet-group"
  subnet_ids = [
    aws_subnet.microservices-subnet-1.id,
    aws_subnet.microservices-subnet-2.id,
    aws_subnet.microservices-subnet-3.id,
  ]
  tags = {
    Name = "microservices-subnet-group"
  }
}
# <<<

# >>> LAMBDA SUBNETS
resource "aws_subnet" "microservices-lambda-subnet-1" {
  vpc_id            = aws_vpc.microservices-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "microservices-lambda-subnet-1"
  }
}

resource "aws_subnet" "microservices-lambda-subnet-2" {
  vpc_id            = aws_vpc.microservices-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-2b"
  tags = {
    Name = "microservices-lambda-subnet-2"
  }
}

resource "aws_subnet" "microservices-lambda-subnet-3" {
  vpc_id            = aws_vpc.microservices-vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-2c"
  tags = {
    Name = "microservices-lambda-subnet-3"
  }
}
# <<<

# >>> VPC SECURITY GROUP
resource "aws_security_group" "microservices-security-group" {
  name        = "microservices-security-group"
  description = "Allow microservices-security-group ports"
  vpc_id      = aws_vpc.microservices-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NFS from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.microservices-vpc.cidr_block]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["140.141.4.62/32"]
    self        = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "microservices-security-group"
  }
}
# <<<

# >>> VPC INTERNET GATEWAY
resource "aws_internet_gateway" "microservices-vpc-gateway" {
  vpc_id = aws_vpc.microservices-vpc.id
  tags = {
    Name = "microservices-vpc-gateway"
  }
}
# <<<

# >>> VPC NETWORK INTERFACE
resource "aws_network_interface" "microservices-network-interface-1" {
  subnet_id       = aws_subnet.microservices-subnet-1.id
  security_groups = [aws_security_group.microservices-security-group.id]
  depends_on      = [aws_internet_gateway.microservices-vpc-gateway]
  tags = {
    Name = "microservices-network-interface-1"
  }
}
# <<<

# >>> VPC NAT GATEWAY
resource "aws_eip" "microservices-eip-1" {
  vpc = true
}

resource "aws_nat_gateway" "microservices-nat-gateway" {
  allocation_id = aws_eip.microservices-eip-1.id
  subnet_id     = aws_subnet.microservices-subnet-1.id
  tags = {
    Name = "microservices-nat-gateway-1"
  }
}
# <<<


# >>> ROUTE TABLE FOR GENERAL PURPOSE
resource "aws_route_table" "microservices-route-table" {
  vpc_id = aws_vpc.microservices-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.microservices-vpc-gateway.id
  }

  tags = {
    Name = "microservices-route-table"
  }
}

resource "aws_route_table_association" "microservices-route-table-assoc-1" {
  subnet_id      = aws_subnet.microservices-subnet-1.id
  route_table_id = aws_route_table.microservices-route-table.id
}

resource "aws_route_table_association" "microservices-route-table-assoc-2" {
  subnet_id      = aws_subnet.microservices-subnet-2.id
  route_table_id = aws_route_table.microservices-route-table.id
}

resource "aws_route_table_association" "microservices-route-table-assoc-3" {
  subnet_id      = aws_subnet.microservices-subnet-3.id
  route_table_id = aws_route_table.microservices-route-table.id
}

resource "aws_main_route_table_association" "microservices-main-route-table-assoc" {
  vpc_id         = aws_vpc.microservices-vpc.id
  route_table_id = aws_route_table.microservices-route-table.id
}
# <<<

# >>> ROUTE TABLE FOR LAMBDA WITH OUTBOUND INTERNET ACCESS
resource "aws_route_table" "microservices-lambda-route-table" {
  vpc_id = aws_vpc.microservices-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.microservices-nat-gateway.id
  }

  tags = {
    Name = "microservices-lambda-route-table"
  }
}

resource "aws_route_table_association" "microservices-lambda-route-table-assoc-1" {
  subnet_id      = aws_subnet.microservices-lambda-subnet-1.id
  route_table_id = aws_route_table.microservices-lambda-route-table.id
}

resource "aws_route_table_association" "microservices-lambda-route-table-assoc-2" {
  subnet_id      = aws_subnet.microservices-lambda-subnet-2.id
  route_table_id = aws_route_table.microservices-lambda-route-table.id
}

resource "aws_route_table_association" "microservices-lambda-route-table-assoc-3" {
  subnet_id      = aws_subnet.microservices-lambda-subnet-3.id
  route_table_id = aws_route_table.microservices-lambda-route-table.id
}
# <<<
