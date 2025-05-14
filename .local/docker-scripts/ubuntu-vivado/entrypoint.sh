#!/bin/bash
set -e

# Get host user UID and GID
USER_ID=${HOST_USER_ID:-1000}
GROUP_ID=${HOST_GROUP_ID:-1000}

echo "Starting with UID: $USER_ID, GID: $GROUP_ID"

# Always use exact host UID and GID
echo "Setting up container user with host UID:GID ($USER_ID:$GROUP_ID)"

# Create or update group
if getent group $GROUP_ID > /dev/null; then
    GROUP_NAME=$(getent group $GROUP_ID | cut -d: -f1)
    echo "Group with GID $GROUP_ID exists: $GROUP_NAME"
else
    echo "Creating group with GID $GROUP_ID"
    groupadd -g $GROUP_ID hostgroup
    GROUP_NAME="hostgroup"
fi

# Create or update user
if getent passwd $USER_ID > /dev/null; then
    EXISTING_USER=$(getent passwd $USER_ID | cut -d: -f1)
    echo "User with UID $USER_ID exists: $EXISTING_USER"
    
    # If the existing user is not named 'user', handle the conflict
    if [ "$EXISTING_USER" != "ubuntu" ]; then
        echo "Renaming user $EXISTING_USER to ubuntu"
        usermod -l ubuntu $EXISTING_USER
        usermod -d /home/ubuntu $EXISTING_USER 2>/dev/null || true
        
        # Fix home directory if needed
        if [ ! -d "/home/ubuntu" ]; then
            mkdir -p /home/ubuntu
        fi
        
        # Ensure user has the correct group
        usermod -g $GROUP_ID ubuntu
    fi
else
    echo "Creating user with UID $USER_ID and GID $GROUP_ID"
    useradd -u $USER_ID -g $GROUP_ID -s /bin/bash -m -d /home/ubuntu ubuntu
fi

# Add to sudo group
if getent group sudo > /dev/null; then
    usermod -aG sudo ubuntu 2>/dev/null || echo "Could not add user to sudo group"
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# Create directories if they don't exist and ensure ownership
mkdir -p /home/ubuntu/tools
mkdir -p /home/ubuntu/Documents
mkdir -p /home/ubuntu/Downloads
mkdir -p /home/ubuntu/.Xilinx
mkdir -p /home/ubuntu/Xilinx
mkdir -p /home/ubuntu/bin

# CRITICAL - This ensures mounted volumes will have correct ownership
chown -R $USER_ID:$GROUP_ID /home/ubuntu/tools
chown -R $USER_ID:$GROUP_ID /home/ubuntu/Documents
chown -R $USER_ID:$GROUP_ID /home/ubuntu/Downloads
chown -R $USER_ID:$GROUP_ID /home/ubuntu/.Xilinx
chown -R $USER_ID:$GROUP_ID /home/ubuntu/Xilinx
chown -R $USER_ID:$GROUP_ID /home/ubuntu/bin
chown -R $USER_ID:$GROUP_ID /home/ubuntu

# Fix X authority permissions
if [ -f /tmp/.docker.xauth ]; then
    chown $USER_ID:$GROUP_ID /tmp/.docker.xauth 2>/dev/null || true
    echo "X authority file configured for user"
fi

# DBus setup for Vitis
if [ -e "/run/dbus/system_bus_socket" ]; then
    echo "System DBus socket found, configuring permissions"
    chmod 777 /run/dbus/system_bus_socket 2>/dev/null || true
fi

# Print information message
echo "Container started with user ubuntu ($USER_ID:$GROUP_ID)"
echo "Mounted directories:"
echo "  - Host Documents → Container /home/ubuntu/Documents"
echo "  - Host tools → Container /home/ubuntu/tools"
echo "  - Host Downloads → Container /home/ubuntu/Downloads"
echo "  - Host .Xilinx → Container /home/ubuntu/.Xilinx"
echo "  - Host Xilinx → Container /home/ubuntu/Xilinx"
echo ""
echo "Display: $DISPLAY"
if [ -n "$WAYLAND_DISPLAY" ]; then
    echo "Wayland Display: $WAYLAND_DISPLAY (running via XWayland)"
fi
echo ""
echo "To test display connectivity, run: test_display.sh"

# Set up Vivado environment as the user
gosu ubuntu /usr/local/bin/setup_vivado_alias.sh

# Set up Vitis environment as the user
gosu ubuntu /usr/local/bin/setup_vitis_alias.sh

# Ensure .bashrc is always loaded for interactive non-login shells too
if ! grep -q "Force loading aliases in all shells" /etc/bash.bashrc; then
    echo "# Force loading aliases in all shells" >> /etc/bash.bashrc
    echo "if [ -f /home/ubuntu/.bashrc ]; then" >> /etc/bash.bashrc
    echo "    . /home/ubuntu/.bashrc" >> /etc/bash.bashrc
    echo "fi" >> /etc/bash.bashrc
fi

cd /home/ubuntu

# If command starts with an option, prepend bash
if [ "${1:0:1}" = '-' ]; then
  set -- bash "$@"
fi

# Execute the command as the user
if [ "$1" = 'bash' ] || [ "$1" = '/bin/bash' ]; then
  exec gosu ubuntu "$@"
else
  exec gosu ubuntu "$@"
fi
