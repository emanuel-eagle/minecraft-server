resource "aws_vpc" "minecraft-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Project = var.project_name
    Name = "minecraft-vpc"
  }
}

resource "aws_subnet" "minecraft-subnet" {
  vpc_id            = aws_vpc.minecraft-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = aws_instance.minecraft-server.availability_zone
  tags = { 
    Name = "minecraft-subnet",
    Project = var.project_name  
  }
}