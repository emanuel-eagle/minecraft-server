resource "aws_security_group" "minecraft-server-sg" {
  name        = "minecraft-server-sg"
  description = "Security group for Minecraft server - allows only Minecraft and SSH"
  vpc_id      = aws_vpc.minecraft-vpc.id

  ingress {
    description = "Minecraft server access from anywhere"
    from_port   = var.minecraft_port_number
    to_port     = var.minecraft_port_number
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "minecraft-server-sg"
    Project = "Minecraft"
  }
}