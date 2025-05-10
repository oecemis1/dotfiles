#!/bin/bash
echo "Display Environment Test"
echo "======================="
echo "DISPLAY: $DISPLAY"
echo "XAUTHORITY: $XAUTHORITY"
echo "User: $(whoami) ($(id -u):$(id -g))"
echo "======================="

echo "Checking for X11 sockets:"
ls -la /tmp/.X11-unix/ || echo "No X11 sockets found"

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
