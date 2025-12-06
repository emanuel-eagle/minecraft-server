resource "aws_vpc" "minecraft-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Project = var.project_name
    Name = "minecraft-vpc"
  }
}

  # Internet Gateway for public subnet access
  resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.minecraft-vpc.id
    tags = {
      Name = "minecraft-igw"
      Project = var.project_name
    }
  }

  # Public subnet for the Minecraft server
  resource "aws_subnet" "minecraft-subnet" {
    vpc_id            = aws_vpc.minecraft-vpc.id
    cidr_block        = "10.0.1.0/24"
    availability_zone = var.availability_zone
    tags = {
      Name = "minecraft-subnet"
      Project = var.project_name
    }
  }

  # Route table and route for internet access
  resource "aws_route_table" "public" {
    vpc_id = aws_vpc.minecraft-vpc.id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
      Name = "minecraft-public-rt"
      Project = var.project_name
    }
  }

  resource "aws_route_table_association" "public_assoc" {
    subnet_id      = aws_subnet.minecraft-subnet.id
    route_table_id = aws_route_table.public.id
  }
