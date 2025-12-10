resource "aws_eip" "ip" {
  domain   = "vpc"
  tags = {
    Name    = "${var.project_name}-eip"
    Project = var.project_name
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.minecraft-server.id
  allocation_id = aws_eip.ip.allocation_id
}