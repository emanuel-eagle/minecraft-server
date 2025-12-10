### GLOBAL VARIABLES ###

variable project_name {
    description = "The name of the project"
    type        = string
    default     = "Minecraft"
}

variable primary_region {
    description = "The primary AWS region to deploy resources"
    type        = string
    default     = "us-east-2"
}

variable "availability_zone" {
    description = "The availability zone to deploy resources"
    type        = string
    default     = "us-east-2b"
}

### EC2 VARIABLES ###
variable "instance_type" {
    description = "Type of EC2 instance to use"
    type        = string
    default     = "t3.micro"
}

variable market_type {
    description = "The spot instance type"
    type        = string
    default     = "spot"
}

variable max_price {
    description = "The spot instance type"
    type        = number
    default     = 0.0033
}

variable spot_instance_type {
    description = "The spot instance type"
    type        = string
    default     = "persistent"
}

variable instance_interruption_behavior {
    description = "The spot instance interruption behavior"
    type        = string
    default     = "stop"
}

variable user_data_script {
    description = "Path to the user data script"
    type        = string
    default     = "minecraft-setup.sh.tpl"
}

variable server_name {
    description = "Name of the Minecraft server"
    type        = string
    default     = "unc-crafting-server-2025"
}

### EBS VARIABLES ###
variable ebs_volume_size {
    description = "Size of the EBS volume in GB"
    type        = number
    default     = 20
}

variable ebs_volume_type {
    description = "Type of the EBS volume"
    type        = string
    default     = "gp3"
}

variable ebs_volume_name {
    description = "Name of EBS volume"
    type = string
    default = "minecraft-world-data"
}

### MINECRAFT VARIABLES ###

variable minecraft_version {
    type        = string
    default     = "1.21.11"
}
variable minecraft_difficulty {
    type        = string
    default     = "easy"
}

variable minecraft_max_players {
    type = number
    default = 4
}

variable minecraft_view_distance {
    type = number
    default = 10
}

variable minecraft_gamemode {
    type = string
    default = "survival"
}

variable minecraft_port_number {
    type = number
    default = 25565
}

variable minecraft_simulation_distance {
    type = number
    default = 10
}

variable minecraft_whitelist {
    description = "Minecraft username for Joshua"
    type        = string
}
