data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "minecraft-server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  iam_instance_profile = aws_iam_instance_profile.minecraft_profile.name
  instance_type = "t3.micro"
  user_data = file("minecraft-setup.sh")
  instance_market_options {
    market_type = "spot"
    spot_options {
        max_price = 0.0033 # minimum max price is 0.0032 
        }
    }
  tags = {
    Project = "Minecraft"
  }
}