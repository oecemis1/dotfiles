#!/bin/bash
echo "Display and System Bus Environment Test"
echo "===================================="
echo "DISPLAY: $DISPLAY"
echo "XAUTHORITY: $XAUTHORITY"
echo "WAYLAND_DISPLAY: $WAYLAND_DISPLAY"
echo "XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR"
echo "User: $(whoami) ($(id -u):$(id -g))"
echo "===================================="

echo "Checking for X11 sockets:"
ls -la /tmp/.X11-unix/ || echo "No X11 sockets found"

echo "Checking for DBus sockets:"
echo "System bus: $(ls -la /run/dbus/system_bus_socket 2>/dev/null || echo 'Not found')"
echo "Session bus: $(ls -la $XDG_RUNTIME_DIR/bus 2>/dev/null || echo 'Not found')"

if [ -n "$WAYLAND_DISPLAY" ] && [ -e "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; then
    echo "Wayland socket found at: $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
    echo "Running under XWayland"
fi

echo "Testing GPU/DRI access:"
if [ -d "/dev/dri" ]; then
    ls -la /dev/dri/
    echo "Running glxinfo to check GPU status:"
    glxinfo | grep -E "OpenGL vendor|OpenGL renderer" || echo "glxinfo not available, installing mesa-utils..."
    if ! command -v glxinfo &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y mesa-utils
        glxinfo | grep -E "OpenGL vendor|OpenGL renderer"
    fi
else
    echo "No DRI devices found, GPU acceleration may not be available"
fi

echo "Testing X11 connection with xeyes:"
if command -v xeyes &> /dev/null; then
    echo "Running xeyes for 5 seconds..."
    xeyes &
    XEYES_PID=$!
    sleep 5
    kill $XEYES_PID 2>/dev/null || echo "xeyes already exited"
else
    echo "xeyes not found, installing x11-apps..."
    sudo apt-get update && sudo apt-get install -y x11-apps
    echo "Running xeyes for 5 seconds..."
    xeyes &
    XEYES_PID=$!
    sleep 5
    kill $XEYES_PID 2>/dev/null || echo "xeyes already exited"
fi

echo ""
echo "If you saw xeyes running, your X11 forwarding is working correctly."
echo ""

# Check if Vitis is installed and test electron app compatibility
if [ -d "$HOME/tools/Xilinx/Vitis" ]; then
    VITIS_VERSION=$(grep "VITIS_VERSION" ~/.bashrc | cut -d '"' -f 2 2>/dev/null || echo "2024.2")
    VITIS_PATH="$HOME/tools/Xilinx/Vitis/$VITIS_VERSION"
    
    if [ -f "$VITIS_PATH/ide/electron-app/lnx64/vitis-ide" ]; then
        echo "Vitis installation found at: $VITIS_PATH"
        echo ""
        echo "Testing Electron compatibility:"
        echo "1. Make sure X11 forwarding works (xeyes test passed)"
        echo "2. Make sure DBus system socket is available"
        echo "3. For Wayland users, check that XWayland is working"
        echo ""
        echo "For best results with Vitis under Wayland:"
        echo "1. Use the vitis-wrapper.sh script in your bin directory"
        echo "2. Or use 'vitis' or 'vitis-gui' aliases from your bashrc"
        echo ""
        echo "If Vitis still has issues:"
        echo "- Try running: LIBGL_ALWAYS_SOFTWARE=1 vitis-wrapper.sh"
        echo "- Or test: ELECTRON_DISABLE_GPU_SANDBOX=1 LIBGL_ALWAYS_SOFTWARE=1 vitis-gui"
    else
        echo "Vitis IDE electron app not found at expected location"
    fi
else
    echo "Vitis installation not found in tools directory"
fi
