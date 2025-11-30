# IAM role for EC2 to use SSM
resource "aws_iam_role" "minecraft_ssm_role" {
  name = "MinecraftServerSSMRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach the AWS managed SSM policy
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.minecraft_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create instance profile
resource "aws_iam_instance_profile" "minecraft_profile" {
  name = "MinecraftServerProfile"
  role = aws_iam_role.minecraft_ssm_role.name
}