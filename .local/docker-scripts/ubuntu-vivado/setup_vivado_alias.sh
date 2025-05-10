#!/bin/bash

# Set Vivado version
VIVADO_VERSION="2024.2"

echo "Setting up Vivado $VIVADO_VERSION environment..."

# Check if already configured to avoid duplicate entries
if ! grep -q "VIVADO_VERSION" "$HOME/.bashrc"; then
    # Add Vivado environment to bashrc
    echo " " >> "$HOME/.bashrc"
    echo "# Vivado environment setup" >> "$HOME/.bashrc"
    echo "export VIVADO_VERSION=\"$VIVADO_VERSION\"" >> "$HOME/.bashrc"
    echo "export VIVADO_HOME=\"\$HOME/tools/Xilinx/Vivado/\$VIVADO_VERSION/\"" >> "$HOME/.bashrc"
    echo "export PATH=\$PATH:\"\$HOME/tools/Xilinx/xic/\"" >> "$HOME/.bashrc"
    echo "export PATH=\$PATH:\"\$HOME/tools/Xilinx/Vivado/\$VIVADO_VERSION/bin\"" >> "$HOME/.bashrc"
    
    # Use the absolute path with specific directory for the vivado command
    echo "alias vivado='/home/user/tools/Xilinx/Vivado/\$VIVADO_VERSION/bin/vivado -nolog -nojournal'" >> "$HOME/.bashrc"
    echo " " >> "$HOME/.bashrc"
    
    echo "Vivado environment configured in .bashrc"
else
    echo "Vivado environment already configured in .bashrc"
fi

# Create a convenience script to install drivers
cat > "$HOME/install_vivado_drivers.sh" << 'EOF'
#!/bin/bash
VIVADO_VERSION=$(grep "VIVADO_VERSION" ~/.bashrc | cut -d '"' -f 2)
DRIVERS_PATH="/home/user/tools/Xilinx/Vivado/$VIVADO_VERSION/data/xicom/cable_drivers/lin64/install_script/install_drivers/"
if [ -d "$DRIVERS_PATH" ]; then
    echo "Installing Xilinx cable drivers..."
    cd "$DRIVERS_PATH"
    sudo ./install_drivers
    echo "Cable drivers installed."
else
    echo "Vivado drivers not found at $DRIVERS_PATH"
    echo "Please ensure Vivado is installed correctly."
fi
EOF
chmod +x "$HOME/install_vivado_drivers.sh"

# Check if drivers already exist and print message
DRIVERS_PATH="/home/user/tools/Xilinx/Vivado/$VIVADO_VERSION/data/xicom/cable_drivers/lin64/install_script/install_drivers/"
if [ -d "$DRIVERS_PATH" ] && [ -x "$DRIVERS_PATH/install_drivers" ]; then
    echo "Found Vivado drivers at $DRIVERS_PATH"
    echo "Run install_vivado_drivers.sh to install them when needed."
fi

echo "Vivado environment setup complete!"
