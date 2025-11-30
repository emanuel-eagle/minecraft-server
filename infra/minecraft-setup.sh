#!/bin/bash
set -e

# Update system
dnf update -y

# Install Java 21
dnf install -y java-21-amazon-corretto-headless

# Create minecraft user
useradd -r -m -U -d /opt/minecraft -s /bin/bash minecraft

# Wait for EBS volume to be attached
echo "Waiting for EBS volume..."
while [ ! -e /dev/sdf ]; do
  sleep 1
done

# Check if volume has a filesystem, create if not
if ! blkid /dev/sdf; then
  echo "Creating filesystem on EBS volume..."
  mkfs -t xfs /dev/sdf
fi

# Create mount point
mkdir -p /opt/minecraft/server

# Mount the volume
mount /dev/sdf /opt/minecraft/server

# Add to fstab for automatic mounting on reboot
if ! grep -q "/dev/sdf" /etc/fstab; then
  echo "/dev/sdf /opt/minecraft/server xfs defaults,nofail 0 2" >> /etc/fstab
fi

# Change to server directory
cd /opt/minecraft/server

# Only download server jar if it doesn't exist (preserves data on restart)
if [ ! -f "server.jar" ]; then
  echo "First time setup - downloading Minecraft server..."
  
  # Download Minecraft server
  MINECRAFT_VERSION="1.21.3"
  wget https://piston-data.mojang.com/v1/objects/45810d238246d90e811d896f87b14695b7fb6839/server.jar -O server.jar
  
  # Accept EULA
  echo "eula=true" > eula.txt
  
  # Create server.properties
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
else
  echo "Existing Minecraft installation detected - preserving data"
fi

# Set ownership
chown -R minecraft:minecraft /opt/minecraft

# Create systemd service
cat > /etc/systemd/system/minecraft.service << 'EOF'
[Unit]
Description=Minecraft Server
After=network.target

[Service]
Type=simple
User=minecraft
WorkingDirectory=/opt/minecraft/server
ExecStart=/usr/bin/java -Xmx512M -Xmx512M -jar server.jar nogui
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable minecraft.service
systemctl start minecraft.service

echo "Minecraft server setup complete!"
echo "World data is stored on persistent EBS volume"
echo "Check status with: sudo systemctl status minecraft"
echo "View logs with: sudo journalctl -u minecraft -f"