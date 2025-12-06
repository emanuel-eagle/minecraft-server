resource "aws_instance" "minecraft-server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  iam_instance_profile = aws_iam_instance_profile.minecraft_profile.name
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.minecraft-server-sg.id]
  subnet_id = aws_subnet.minecraft-subnet.id
  associate_public_ip_address = true

  # Ensure network infra (IGW + public route association) exists before instance/EIP association
  depends_on = [
    aws_internet_gateway.igw,
    aws_route_table_association.public_assoc
  ]
  availability_zone = var.availability_zone
  user_data = templatefile(var.user_data_script, {
    server_ip = aws_eip.ip.public_ip
    difficulty = var.minecraft_difficulty
    max_players = var.minecraft_max_players
    view_distance = var.minecraft_view_distance
    gamemode = var.minecraft_gamemode 
    port = var.minecraft_port_number
    simulation_distance = var.minecraft_simulation_distance
    # Build a JSON array of whitelist entries with empty UUIDs so the server can resolve UUIDs
    whitelist_json = jsonencode([for name in compact([var.joshua_username, var.boner, var.lord_big_mac, var.myself]) : { uuid = "", name = name }])

  })
  instance_market_options {
    market_type = var.market_type
    spot_options {
        max_price = var.max_price # minimum max price is 0.0032 for t3.micro in us-east-2
        spot_instance_type = var.spot_instance_type
        instance_interruption_behavior = var.instance_interruption_behavior
        }
    }
  tags = {
    Project = var.project_name
    Name = var.server_name
  }
}