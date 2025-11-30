#!/bin/bash
set -e

# Update system
dnf update -y

# Install Java 21 (required for Minecraft 1.20+)
dnf install -y java-21-amazon-corretto-headless

# Create minecraft user
useradd -r -m -U -d /opt/minecraft -s /bin/bash minecraft

# Create minecraft directory
mkdir -p /opt/minecraft/server
cd /opt/minecraft/server

# Download Minecraft server (latest version - update URL as needed)
# This downloads version 1.21.3 - check https://www.minecraft.net/en-us/download/server for latest
MINECRAFT_VERSION="1.21.3"
wget https://piston-data.mojang.com/v1/objects/45810d238246d90e811d896f87b14695b7fb6839/server.jar -O server.jar

# Accept EULA
echo "eula=true" > eula.txt

# Create server.properties with basic settings
cat > server.properties << 'EOF'
# Minecraft server properties
enable-jmx-monitoring=false
rcon.port=25575
level-seed=
gamemode=survival
enable-command-block=false
enable-query=false
generator-settings={}
enforce-secure-profile=true
level-name=world
motd=A Minecraft Server on AWS
query.port=25565
pvp=true
generate-structures=true
max-chained-neighbor-updates=1000000
difficulty=easy
network-compression-threshold=256
max-tick-time=60000
require-resource-pack=false
use-native-transport=true
max-players=20
online-mode=true
enable-status=true
allow-flight=false
initial-disabled-packs=
broadcast-rcon-to-ops=true
view-distance=10
server-ip=
resource-pack-prompt=
allow-nether=true
server-port=25565
enable-rcon=false
sync-chunk-writes=true
op-permission-level=4
prevent-proxy-connections=false
hide-online-players=false
resource-pack=
entity-broadcast-range-percentage=100
simulation-distance=10
rcon.password=
player-idle-timeout=0
force-gamemode=false
rate-limit=0
hardcore=false
white-list=false
broadcast-console-to-ops=true
spawn-npcs=true
spawn-animals=true
function-permission-level=2
initial-enabled-packs=vanilla
level-type=minecraft\:normal
text-filtering-config=
spawn-monsters=true
enforce-whitelist=false
spawn-protection=16
resource-pack-sha1=
max-world-size=29999984
EOF

# Create systemd service
cat > /etc/systemd/system/minecraft.service << 'EOF'
[Unit]
Description=Minecraft Server
After=network.target

[Service]
Type=simple
User=minecraft
WorkingDirectory=/opt/minecraft/server
ExecStart=/usr/bin/java -Xmx512M -Xms512M -jar server.jar nogui
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Set ownership
chown -R minecraft:minecraft /opt/minecraft

# Enable and start service
systemctl daemon-reload
systemctl enable minecraft.service
systemctl start minecraft.service

# Configure firewall (if using)
# Uncomment these if you're using firewalld
# firewall-cmd --permanent --add-port=25565/tcp
# firewall-cmd --reload

echo "Minecraft server setup complete!"
echo "Server is starting up - it may take a few minutes to generate the world"
echo "Check status with: sudo systemctl status minecraft"
echo "View logs with: sudo journalctl -u minecraft -f"