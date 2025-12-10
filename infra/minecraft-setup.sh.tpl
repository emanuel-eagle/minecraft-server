#!/bin/bash
set -e

# Update system
dnf update -y

# Install Java 21
dnf install -y java-21-amazon-corretto-headless

# Create minecraft user
useradd -r -m -U -d /opt/minecraft -s /bin/bash minecraft || true

# Wait for EBS volume and detect device name (NVMe or legacy)
DEVICE=""
echo "Waiting for EBS volume..."
for i in {1..60}; do
  if [ -e /dev/nvme1n1 ]; then
    DEVICE="/dev/nvme1n1"
    echo "Found EBS volume at $DEVICE (NVMe)"
    break
  elif [ -e /dev/sdf ]; then
    DEVICE="/dev/sdf"
    echo "Found EBS volume at $DEVICE (legacy)"
    break
  fi
  sleep 1
done

if [ -z "$DEVICE" ]; then
  echo "ERROR: EBS volume not found after 60 seconds"
  exit 1
fi

# Check if volume has a filesystem, create if not
if ! blkid $DEVICE; then
  echo "Creating XFS filesystem on EBS volume..."
  mkfs -t xfs $DEVICE
fi

# Create mount point
mkdir -p /opt/minecraft/server

# Mount the volume
mount $DEVICE /opt/minecraft/server

# Add to fstab for automatic mounting on reboot (use UUID for reliability)
VOLUME_UUID=$(blkid -s UUID -o value $DEVICE)
if ! grep -q "$VOLUME_UUID" /etc/fstab; then
  echo "UUID=$VOLUME_UUID /opt/minecraft/server xfs defaults,nofail 0 2" >> /etc/fstab
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
rcon.port=${port}
level-seed=
gamemode=${gamemode}
enable-command-block=false
enable-query=false
generator-settings={}
enforce-secure-profile=true
level-name=world
motd=A Minecraft Server on AWS
query.port=${port}
pvp=true
generate-structures=true
max-chained-neighbor-updates=1000000
difficulty=${difficulty}
network-compression-threshold=256
max-tick-time=60000
require-resource-pack=false
use-native-transport=true
max-players=${max_players}
online-mode=true
enable-status=true
allow-flight=false
initial-disabled-packs=
broadcast-rcon-to-ops=true
view-distance=${view_distance}
server-ip=${server_ip}
resource-pack-prompt=
allow-nether=true
server-port=${port}
enable-rcon=false
sync-chunk-writes=true
op-permission-level=4
prevent-proxy-connections=false
hide-online-players=false
resource-pack=
entity-broadcast-range-percentage=100
simulation-distance=${simulation_distance}
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

# Whitelist disabled for testing - skip whitelist.json creation
echo "Whitelist disabled - server is open to all players"

# Set ownership
chown -R minecraft:minecraft /opt/minecraft

# Create systemd service (increased memory for better performance)
cat > /etc/systemd/system/minecraft.service << 'EOF'
[Unit]
Description=Minecraft Server
After=network.target

[Service]
Type=simple
User=minecraft
WorkingDirectory=/opt/minecraft/server
ExecStart=/usr/bin/java -Xms512M -Xmx1024M -jar server.jar nogui
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable minecraft.service
systemctl start minecraft.service

echo "Minecraft server setup complete!"
echo "World data is stored on persistent EBS volume at $DEVICE"
echo "Server is OPEN - no whitelist enabled (testing mode)"
echo "Check status with: sudo systemctl status minecraft"
echo "View logs with: sudo journalctl -u minecraft -f"