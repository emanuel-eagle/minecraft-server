resource "aws_vpc" "minecraft-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Project = var.project_name
  }
}