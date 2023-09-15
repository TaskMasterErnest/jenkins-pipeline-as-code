#################################### VPC ########################################
# create the VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_address_space
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-vpc" }))
}


#################################### SUBNETS ########################################
# Create two public subnets 
resource "aws_subnet" "public_subnet01" {
  vpc_id = aws_vpc.vpc.id 
  cidr_block = cidrsubnet("${aws_vpc.vpc.cidr_block}", 3, 0)
  availability_zone = var.zones[0]
  map_public_ip_on_launch = true

  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-public_subnet01" }))
}
resource "aws_subnet" "public_subnet02" {
  vpc_id = aws_vpc.vpc.id 
  cidr_block = cidrsubnet("${aws_vpc.vpc.cidr_block}", 3, 1)
  availability_zone = var.zones[1]
  map_public_ip_on_launch = true
  
  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-public_subnet02" }))
}

# Create two private subnets 
resource "aws_subnet" "private_subnet01" {
  vpc_id = aws_vpc.vpc.id 
  cidr_block = cidrsubnet("${aws_vpc.vpc.cidr_block}", 3, 2)
  availability_zone = var.zones[0]
  map_public_ip_on_launch = false

  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-private_subnet01" }))
}
resource "aws_subnet" "private_subnet02" {
  vpc_id = aws_vpc.vpc.id 
  cidr_block = cidrsubnet("${aws_vpc.vpc.cidr_block}", 3, 3)
  availability_zone = var.zones[1]
  map_public_ip_on_launch = false
  
  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-private_subnet02" }))
}


#################################### INTERNET GATEWAY ########################################
# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.vpc.id 
  
  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-igw" }))
}


#################################### PUBLIC ROUTE TABLE INFORMATION ########################################
# Create a Public route table for the public subnets
resource "aws_route_table" "public_igw_route" {
  vpc_id = aws_vpc.vpc.id 
  
  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-public_route_table" }))

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id 
  }
}

# Create a Route table association for the public subnets
resource "aws_route_table_association" "rta_subnet_public01" {
  subnet_id = aws_subnet.public_subnet01.id 
  route_table_id = aws_route_table.public_igw_route.id 
}
resource "aws_route_table_association" "rta_subnet_public02" {
  subnet_id = aws_subnet.public_subnet02.id 
  route_table_id = aws_route_table.public_igw_route.id 
}


#################################### ELASTIC IP ADDRESS & NAT GATEWAY ########################################
# create the elastic IP resource
resource "aws_eip" "elastic_ip_nat" {
  domain = "vpc"
  depends_on = [ aws_internet_gateway.vpc_igw ]

  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-nat_gw_elastic_ip" }))
}

# create the NAT gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.elastic_ip_nat.id
  subnet_id = aws_subnet.public_subnet01.id

  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-nat_gw" }))
}


#################################### PRIVATE ROUTE TABLE INFORMATION ########################################
# Create the private route table
resource "aws_route_table" "private_igw_route" {
  vpc_id = aws_vpc.vpc.id 
  
  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-private_route_table" }))

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id 
  }
}

# Create a Route table association for the private subnets
resource "aws_route_table_association" "rta_subnet_private01" {
  subnet_id = aws_subnet.private_subnet01.id 
  route_table_id = aws_route_table.private_igw_route.id 
}
resource "aws_route_table_association" "rta_subnet_private02" {
  subnet_id = aws_subnet.private_subnet02.id 
  route_table_id = aws_route_table.private_igw_route.id 
}