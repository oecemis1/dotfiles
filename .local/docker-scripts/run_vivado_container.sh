#!/usr/bin/env bash

# Container name
CONTAINER_NAME="vivado-container"

# Image name
IMAGE_NAME="vivado-environment"

# Get your user information
HOST_USER=$(whoami)
HOST_UID=$(id -u)
HOST_GID=$(id -g)

# Host directories to mount
HOST_HOME="$HOME"
DOCUMENTS_DIR="$HOST_HOME/Documents"
TOOLS_DIR="$HOST_HOME/tools"
DOWNLOADS_DIR="$HOST_HOME/Downloads"
XILINX_DIR="$HOST_HOME/.Xilinx"
XILINX_PROJ_DIR="$HOST_HOME/Xilinx"

# Create directories if they don't exist
mkdir -p "$DOCUMENTS_DIR"
mkdir -p "$TOOLS_DIR"
mkdir -p "$DOWNLOADS_DIR"
mkdir -p "$XILINX_DIR"
mkdir -p "$XILINX_PROJ_DIR"

# Ensure we have permission to these directories before mounting
if [ ! -w "$DOCUMENTS_DIR" ] || [ ! -w "$TOOLS_DIR" ] || [ ! -w "$DOWNLOADS_DIR" ] || [ ! -w "$XILINX_DIR" ] || [ ! -w "$XILINX_PROJ_DIR" ]; then
    echo "Warning: You don't have write permission to one or more directories."
    echo "This will cause permission issues inside the container."
    echo "Would you like to fix permissions now? (y/n)"
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        # Fix permissions using sudo
        sudo chown -R $HOST_UID:$HOST_GID "$DOCUMENTS_DIR" "$TOOLS_DIR" "$DOWNLOADS_DIR" "$XILINX_DIR" "$XILINX_PROJ_DIR"
        sudo chmod -R u+rwX "$DOCUMENTS_DIR" "$TOOLS_DIR" "$DOWNLOADS_DIR" "$XILINX_DIR" "$XILINX_PROJ_DIR"
        echo "Permissions fixed."
    else
        echo "Continuing without fixing permissions. You may encounter issues."
    fi
fi

# Create a persistent xauth file in the user's home directory if it doesn't exist
XAUTH_DIR="$HOME/.docker"
XAUTH_FILE="$XAUTH_DIR/docker-xauth"
mkdir -p "$XAUTH_DIR"

# Default DISPLAY if not set
if [ -z "$DISPLAY" ]; then
    # Try to auto-detect display
    if [ -n "$WAYLAND_DISPLAY" ]; then
        # Running under Wayland
        export DISPLAY=:0
        echo "Wayland detected, setting DISPLAY to $DISPLAY"
    else
        # Assume X11
        export DISPLAY=:0
        echo "Set DISPLAY to $DISPLAY"
    fi
fi

# Setup for both X11 and Wayland
if command -v xhost &> /dev/null; then
    xhost +local: >/dev/null 2>&1
    echo "X11 local connections enabled"
fi

# Create a persistent directory for container configuration
CONFIG_DIR="$HOME/.docker/vivado-config"
mkdir -p "$CONFIG_DIR"

# Regenerate xauth file (clean and create new)
XAUTH_FILE="$CONFIG_DIR/docker-xauth"
touch "$XAUTH_FILE"
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f "$XAUTH_FILE" nmerge -
chmod 644 "$XAUTH_FILE"
echo "X authentication file created at $XAUTH_FILE"

# DBus socket parameters
DBUS_PARAMS=""
if [ -e "/run/dbus/system_bus_socket" ]; then
    DBUS_PARAMS="-v /run/dbus/system_bus_socket:/run/dbus/system_bus_socket"
    echo "System DBus socket mounted"
fi

# Wayland specific setup with enhanced graphics support
WAYLAND_PARAMS=""
if [ -n "$WAYLAND_DISPLAY" ] && [ -e "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; then
    echo "Configuring Wayland support"
    WAYLAND_PARAMS="-v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
    
    # If XDG_RUNTIME_DIR exists, also mount it
    if [ -n "$XDG_RUNTIME_DIR" ]; then
        WAYLAND_PARAMS="$WAYLAND_PARAMS -v $XDG_RUNTIME_DIR:$XDG_RUNTIME_DIR"
        WAYLAND_PARAMS="$WAYLAND_PARAMS -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
        WAYLAND_PARAMS="$WAYLAND_PARAMS -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
        WAYLAND_PARAMS="$WAYLAND_PARAMS -e GDK_BACKEND=wayland,x11"
        WAYLAND_PARAMS="$WAYLAND_PARAMS -e QT_QPA_PLATFORM=wayland"
        WAYLAND_PARAMS="$WAYLAND_PARAMS -e CLUTTER_BACKEND=wayland"
        WAYLAND_PARAMS="$WAYLAND_PARAMS -e SDL_VIDEODRIVER=wayland"
    fi
    
    # Add DRI device for GPU acceleration
    if [ -d "/dev/dri" ]; then
        WAYLAND_PARAMS="$WAYLAND_PARAMS -v /dev/dri:/dev/dri --device /dev/dri"
        echo "DRI devices mounted for GPU acceleration"
    fi
fi

# Check if container is running
if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
    echo "Container $CONTAINER_NAME is already running."
    echo "Attaching to container as user..."
    # Always exec as user with login shell (-l) to ensure .bash_profile is loaded
    docker exec -it -u ubuntu -w /home/ubuntu "$CONTAINER_NAME" bash -l
    exit 0
fi

# If container exists but is stopped, start it instead of removing
if docker ps -a -q -f name="$CONTAINER_NAME" | grep -q .; then
    echo "Container $CONTAINER_NAME exists but is stopped."
    echo "Starting it again..."
    docker start "$CONTAINER_NAME"
    # Always exec as user with login shell (-l) to ensure .bash_profile is loaded
    docker exec -it -u ubuntu -w /home/ubuntu "$CONTAINER_NAME" bash -l
    exit 0
fi

# At this point, we're creating a new container
echo "Creating new container $CONTAINER_NAME..."

# Create the new container with X11, DBus, and optional Wayland support
docker run -it \
    --name "$CONTAINER_NAME" \
    -v "$DOCUMENTS_DIR":/home/ubuntu/Documents \
    -v "$TOOLS_DIR":/home/ubuntu/tools \
    -v "$DOWNLOADS_DIR":/home/ubuntu/Downloads \
    -v "$XILINX_DIR":/home/ubuntu/.Xilinx \
    -v "$XILINX_PROJ_DIR":/home/ubuntu/Xilinx \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "$XAUTH_FILE":/tmp/.docker.xauth \
    $DBUS_PARAMS \
    $WAYLAND_PARAMS \
    -e DISPLAY="$DISPLAY" \
    -e XAUTHORITY=/tmp/.docker.xauth \
    -e HOST_USER_ID="$HOST_UID" \
    -e HOST_GROUP_ID="$HOST_GID" \
    -e DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${HOST_UID}/bus" \
    --ipc=host \
    --net=host \
    --privileged \
    "$IMAGE_NAME"

# Check if container started successfully
if [ $? -ne 0 ]; then
    echo "Error: Failed to start container."
    exit 1
fi
