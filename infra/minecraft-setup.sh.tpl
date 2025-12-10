#!/bin/bash
set -e

# Update and install Java
dnf update -y
dnf install -y java-21-amazon-corretto-headless

# Create minecraft user
useradd -r -m -U -d /opt/minecraft -s /bin/bash minecraft || true

# Wait for and mount EBS volume
DEVICE=""
for i in {1..300}; do
  if [ -e /dev/nvme1n1 ]; then
    DEVICE="/dev/nvme1n1"
    break
  elif [ -e /dev/sdf ]; then
    DEVICE="/dev/sdf"
    break
  fi
  sleep 1
done

if [ -z "$DEVICE" ]; then
  echo "ERROR: EBS volume not found"
  exit 1
fi

# Format if needed
if ! blkid $DEVICE; then
  mkfs -t xfs $DEVICE
fi

# Mount
mkdir -p /opt/minecraft/server
mount $DEVICE /opt/minecraft/server

# Add to fstab
VOLUME_UUID=$(blkid -s UUID -o value $DEVICE)
if ! grep -q "$VOLUME_UUID" /etc/fstab; then
  echo "UUID=$VOLUME_UUID /opt/minecraft/server xfs defaults,nofail 0 2" >> /etc/fstab
fi

cd /opt/minecraft/server

# Download server on first run only
if [ ! -f "server.jar" ]; then
  echo "Downloading Minecraft ${minecraft_version}..."
  
  # Get version manifest URL
  VERSION_URL=$(curl -s https://piston-meta.mojang.com/mc/game/version_manifest_v2.json | \
    jq -r ".versions[] | select(.id==\"${minecraft_version}\") | .url")
  
  if [ -z "$VERSION_URL" ] || [ "$VERSION_URL" = "null" ]; then
    echo "ERROR: Version ${minecraft_version} not found"
    exit 1
  fi
  
  # Get server download URL
  SERVER_URL=$(curl -s $VERSION_URL | jq -r '.downloads.server.url')
  
  if [ -z "$SERVER_URL" ] || [ "$SERVER_URL" = "null" ]; then
    echo "ERROR: Server download URL not found for ${minecraft_version}"
    exit 1
  fi
  
  # Download
  wget -q $SERVER_URL -O server.jar
  echo "Downloaded Minecraft ${minecraft_version}"
  
  echo "eula=true" > eula.txt
fi


# Always create/update these files
cat > server.properties << EOF
server-port=${port}
server-ip=
gamemode=${gamemode}
difficulty=${difficulty}
max-players=${max_players}
view-distance=${view_distance}
simulation-distance=${simulation_distance}
white-list=true
enforce-whitelist=true
online-mode=true
motd=Minecraft on AWS
EOF

echo '${whitelist_json}' > whitelist.json

# Fix ownership
chown -R minecraft:minecraft /opt/minecraft

# Create service
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

[Install]
WantedBy=multi-user.target
EOF

# Start
systemctl daemon-reload
systemctl enable minecraft.service
systemctl start minecraft.service

echo "Done!"