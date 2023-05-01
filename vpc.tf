resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Terraform"
  }
}
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "public"
  }
}
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "private"
  }
}

resource "aws_internet_gateway" "terraform-gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "terraform-gw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-gw.id
  }
  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "lb" {
    tags = {
        Name = "terraform"
    }
}
resource "aws_nat_gateway" "terraform" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "gw NAT"
  }
  depends_on = [aws_internet_gateway.terraform-gw]
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.terraform.id
  }
  tags = {
    Name = "private"
  }
}