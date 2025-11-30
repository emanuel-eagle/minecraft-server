
resource "aws_ebs_volume" "minecraft_data" {
  availability_zone = aws_spot_instance_request.minecraft_server.availability_zone
  size              = 20  # GB - adjust based on your needs
  type              = "gp3"
  
  tags = {
    Name = "Minecraft-World-Data"
    Project = "Minecraft"
  }
}

# Attach the volume to the instance
resource "aws_volume_attachment" "minecraft_data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.minecraft_data.id
  instance_id = aws_instance.minecraft-server.id
  skip_destroy = true
}