#!/bin/bash
echo "Display Environment Test"
echo "======================="
echo "DISPLAY: $DISPLAY"
echo "XAUTHORITY: $XAUTHORITY"
echo "WAYLAND_DISPLAY: $WAYLAND_DISPLAY"
echo "XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR"
echo "User: $(whoami) ($(id -u):$(id -g))"
echo "======================="

echo "Checking for X11 sockets:"
ls -la /tmp/.X11-unix/ || echo "No X11 sockets found"

if [ -n "$WAYLAND_DISPLAY" ] && [ -e "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; then
    echo "Wayland socket found at: $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
    echo "Running under XWayland"
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
echo "You should be able to run Vivado GUI without issues."
echo ""
echo "For Wayland users: Vivado runs via XWayland, which should be working if xeyes displayed correctly."
