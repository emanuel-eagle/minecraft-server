
# resource "aws_ebs_volume" "minecraft_data" {
#   availability_zone = var.availability_zone
#   size              = var.ebs_volume_size
#   type              = var.ebs_volume_type
  
#   tags = {
#     Name = var.ebs_volume_name
#     Project = var.project_name
#   }
# }

# # Attach the volume to the instance
# resource "aws_volume_attachment" "minecraft_data" {
#   device_name = "/dev/sdf"
#   volume_id   = aws_ebs_volume.minecraft_data.id
#   instance_id = aws_instance.minecraft-server.id
#   force_detach = true       
#   skip_destroy = false      
#   stop_instance_before_detaching = false
# }

# resource "aws_ebs_snapshot" "minecraft_data_snapshot" {
#   volume_id = aws_ebs_volume.minecraft_data.id
#   region = var.primary_region
#   tags = {
#     Name = "${var.ebs_volume_name}-snapshot"
#     Project = var.project_name
#   }
# }