
resource "aws_ebs_volume" "minecraft_data" {
  availability_zone = aws_instance.minecraft-server.availability_zone
  size              = var.ebs_volume_size
  type              = var.ebs_volume_type
  
  tags = {
    Name = var.ebs_volume_name
    Project = var.project_name
  }
}

# Attach the volume to the instance
resource "aws_volume_attachment" "minecraft_data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.minecraft_data.id
  instance_id = aws_instance.minecraft-server.id
  skip_destroy = true
}