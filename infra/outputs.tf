output "public_ip" {
    value = aws_eip.ip.public_ip
    description = "The public IP address of the Minecraft server. This is what you send to the boys"
}