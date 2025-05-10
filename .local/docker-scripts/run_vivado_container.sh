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

# Allow local X server connections if xhost is available
if command -v xhost &> /dev/null; then
    xhost +local: >/dev/null 2>&1
    echo "X11 local connections enabled"
else
    echo "xhost command not found. X11 forwarding might not work correctly."
fi

# Check if container is running
if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
    echo "Container $CONTAINER_NAME is already running."
    echo "Attaching to container..."
    docker exec -it -w /home/user "$CONTAINER_NAME" bash
    exit 0
fi

# If container exists but is stopped, remove it and create a new one
if docker ps -a -q -f name="$CONTAINER_NAME" | grep -q .; then
    echo "Container $CONTAINER_NAME exists but is stopped."
    echo "Removing it and creating a new one..."
    docker rm "$CONTAINER_NAME"
fi

# At this point, we're creating a new container
echo "Creating new container $CONTAINER_NAME..."

# Default DISPLAY if not set
if [ -z "$DISPLAY" ]; then
    export DISPLAY=:0
    echo "Set DISPLAY to $DISPLAY"
fi

# Set up X11 forwarding for the new container
echo "Setting up X11 forwarding for new container..."
XAUTH_FILE=$(mktemp /tmp/docker-xauth-XXXXXX)
touch $XAUTH_FILE
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH_FILE nmerge -
chmod 644 $XAUTH_FILE

# Create the new container
docker run -it \
    --name "$CONTAINER_NAME" \
    -v "$DOCUMENTS_DIR":/home/user/Documents \
    -v "$TOOLS_DIR":/home/user/tools \
    -v "$DOWNLOADS_DIR":/home/user/Downloads \
    -v "$XILINX_DIR":/home/user/.Xilinx \
    -v "$XILINX_PROJ_DIR":/home/user/Xilinx \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "$XAUTH_FILE":/tmp/.docker.xauth \
    -e DISPLAY="$DISPLAY" \
    -e XAUTHORITY=/tmp/.docker.xauth \
    -e HOST_USER_ID="$HOST_UID" \
    -e HOST_GROUP_ID="$HOST_GID" \
    --ipc=host \
    --net=host \
    "$IMAGE_NAME"

# Clean up the temporary X authority file
rm -f $XAUTH_FILE

# Check if container started successfully
if [ $? -ne 0 ]; then
    echo "Error: Failed to start container."
    exit 1
fi
