#!/bin/bash

# Set Vitis version
VITIS_VERSION="2024.2"

echo "Setting up Vitis $VITIS_VERSION environment..."

# Check if already configured to avoid duplicate entries
if ! grep -q "VITIS_VERSION" "$HOME/.bashrc"; then
    # Add Vitis environment to bashrc
    echo " " >> "$HOME/.bashrc"
    echo "# Vitis environment setup" >> "$HOME/.bashrc"
    echo "export VITIS_VERSION=\"$VITIS_VERSION\"" >> "$HOME/.bashrc"
    echo "export VITIS_HOME=\"\$HOME/tools/Xilinx/Vitis/\$VITIS_VERSION/\"" >> "$HOME/.bashrc"
    echo "export PATH=\$PATH:\"\$HOME/tools/Xilinx/Vitis/\$VITIS_VERSION/bin\"" >> "$HOME/.bashrc"
    
    # Wayland and GPU environment fixes
    echo " " >> "$HOME/.bashrc"
    echo "# Electron app fixes for Wayland" >> "$HOME/.bashrc"
    echo "export ELECTRON_DISABLE_GPU_SANDBOX=1" >> "$HOME/.bashrc"
    echo "export ELECTRON_FORCE_DEVICE_SCALE_FACTOR=1" >> "$HOME/.bashrc"
    echo "export MESA_LOADER_DRIVER_OVERRIDE=iris" >> "$HOME/.bashrc"
    echo "export LIBGL_ALWAYS_SOFTWARE=1" >> "$HOME/.bashrc"
    
    # Setup aliases for Vitis
    echo "alias vitis='cd \$HOME/Xilinx && \$HOME/tools/Xilinx/Vitis/\$VITIS_VERSION/ide/electron-app/lnx64/vitis-ide --no-sandbox --disable-gpu'" >> "$HOME/.bashrc"
    echo "alias vitis-gui='\$HOME/tools/Xilinx/Vitis/\$VITIS_VERSION/ide/electron-app/lnx64/vitis-ide --no-sandbox --disable-gpu'" >> "$HOME/.bashrc"
    echo "alias vitis-create='cd \$HOME/Xilinx && \$HOME/tools/Xilinx/Vitis/\$VITIS_VERSION/bin/vitis -wlwc'" >> "$HOME/.bashrc"
    
    echo "Vitis environment configured in .bashrc"
else
    echo "Vitis environment already configured in .bashrc"
fi

# Create wrapper script for Vitis with fixes
cat > "$HOME/bin/vitis-wrapper.sh" << 'EOF'
#!/bin/bash
# Wrapper script for Vitis IDE with Wayland/DBus fixes
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus
export ELECTRON_DISABLE_GPU_SANDBOX=1
export ELECTRON_FORCE_DEVICE_SCALE_FACTOR=1
export MESA_LOADER_DRIVER_OVERRIDE=iris
export LIBGL_ALWAYS_SOFTWARE=1

# Run Vitis with options that help with Wayland/GPU issues
VITIS_VERSION=$(grep "VITIS_VERSION" ~/.bashrc | cut -d '"' -f 2)
$HOME/tools/Xilinx/Vitis/${VITIS_VERSION}/ide/electron-app/lnx64/vitis-ide --no-sandbox --disable-gpu "$@"
EOF
chmod +x "$HOME/bin/vitis-wrapper.sh"

# Ensure bin directory is in PATH
if ! grep -q "PATH.*bin" "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo "Vitis environment setup complete!"
echo "Available aliases:"
echo "  - vitis      : Change to Xilinx directory and launch Vitis IDE with fixes"
echo "  - vitis-gui  : Launch Vitis IDE with fixes"
echo "  - vitis-create : Launch Vitis in workspace creation mode"
echo ""
echo "Helper scripts:"
echo "  - vitis-wrapper.sh : Wrapper script with environment fixes for Vitis"
echo ""
echo "Note: For best results with Vitis under Wayland, use the vitis-wrapper.sh script"
echo "      or the vitis and vitis-gui aliases."
