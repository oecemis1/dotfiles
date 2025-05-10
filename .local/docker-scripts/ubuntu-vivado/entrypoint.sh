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
    if [ "$EXISTING_USER" != "user" ]; then
        echo "Renaming user $EXISTING_USER to user"
        usermod -l user $EXISTING_USER
        usermod -d /home/user $EXISTING_USER 2>/dev/null || true
        
        # Fix home directory if needed
        if [ ! -d "/home/user" ]; then
            mkdir -p /home/user
        fi
        
        # Ensure user has the correct group
        usermod -g $GROUP_ID user
    fi
else
    echo "Creating user with UID $USER_ID and GID $GROUP_ID"
    useradd -u $USER_ID -g $GROUP_ID -s /bin/bash -m -d /home/user user
fi

# Add to sudo group
if getent group sudo > /dev/null; then
    usermod -aG sudo user 2>/dev/null || echo "Could not add user to sudo group"
    echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# Create directories if they don't exist and ensure ownership
mkdir -p /home/user/tools
mkdir -p /home/user/Documents
mkdir -p /home/user/Downloads
mkdir -p /home/user/.Xilinx

# CRITICAL - This ensures mounted volumes will have correct ownership
chown -R $USER_ID:$GROUP_ID /home/user/tools
chown -R $USER_ID:$GROUP_ID /home/user/Documents
chown -R $USER_ID:$GROUP_ID /home/user/Downloads
chown -R $USER_ID:$GROUP_ID /home/user/.Xilinx
chown -R $USER_ID:$GROUP_ID /home/user

# Fix X authority permissions
if [ -f /tmp/.docker.xauth ]; then
    chown $USER_ID:$GROUP_ID /tmp/.docker.xauth 2>/dev/null || true
    echo "X authority file configured for user"
fi

# Print information message
echo "Container started with user user ($USER_ID:$GROUP_ID)"
echo "Mounted directories:"
echo "  - Host Documents → Container /home/user/Documents"
echo "  - Host tools → Container /home/user/tools"
echo "  - Host Downloads → Container /home/user/Downloads"
echo "  - Host .Xilinx → Container /home/user/.Xilinx"
echo ""
echo "Display: $DISPLAY"
echo ""
echo "To test display connectivity, run: test_display.sh"

# Set up Vivado environment as the user
gosu user /usr/local/bin/setup_vivado_alias.sh

cd /home/user

# If command starts with an option, prepend bash
if [ "${1:0:1}" = '-' ]; then
  set -- bash "$@"
fi

# Execute the command as the user
if [ "$1" = 'bash' ] || [ "$1" = '/bin/bash' ]; then
  exec gosu user "$@"
else
  exec gosu user "$@"
fi
