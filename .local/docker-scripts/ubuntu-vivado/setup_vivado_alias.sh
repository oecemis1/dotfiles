#!/bin/bash

# Set Vivado version
VIVADO_VERSION="2020.2"

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
    # Custom board files (au200 / Alveo U200, etc.) so Vivado can find them via get_board_parts
    echo "export BOARD_PART_REPO_PATHS=\"\$HOME/tools/Xilinx/board_files\"" >> "$HOME/.bashrc"
    
    # Use the absolute path with specific directory for the vivado command
    echo "alias vivado='/home/ubuntu/tools/Xilinx/Vivado/\$VIVADO_VERSION/bin/vivado -nolog -nojournal'" >> "$HOME/.bashrc"
    echo "alias vstart='cd \$HOME/Xilinx && vivado'" >> "$HOME/.bashrc"
    echo "alias vsyn='vivado -mode batch -source'" >> "$HOME/.bashrc"
    echo "alias vgui='vivado -mode gui'" >> "$HOME/.bashrc"
    echo "alias vtcl='vivado -mode tcl'" >> "$HOME/.bashrc"
    
    echo "Vivado environment configured in .bashrc"
else
    echo "Vivado environment already configured in .bashrc"
fi

# Ensure .bash_profile exists and sources .bashrc
if [ ! -f "$HOME/.bash_profile" ]; then
    echo "Creating .bash_profile to ensure .bashrc is loaded in login shells"
    echo "# Load .bashrc for login shells" > "$HOME/.bash_profile"
    echo "if [ -f \"\$HOME/.bashrc\" ]; then" >> "$HOME/.bash_profile"
    echo "    source \"\$HOME/.bashrc\"" >> "$HOME/.bash_profile"
    echo "fi" >> "$HOME/.bash_profile"
fi

# Create a convenience script to install drivers
cat > "$HOME/install_vivado_drivers.sh" << 'EOF'
#!/bin/bash
VIVADO_VERSION=$(grep "VIVADO_VERSION" ~/.bashrc | cut -d '"' -f 2)
DRIVERS_PATH="/home/ubuntu/tools/Xilinx/Vivado/$VIVADO_VERSION/data/xicom/cable_drivers/lin64/install_script/install_drivers/"
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
DRIVERS_PATH="/home/ubuntu/tools/Xilinx/Vivado/$VIVADO_VERSION/data/xicom/cable_drivers/lin64/install_script/install_drivers/"
if [ -d "$DRIVERS_PATH" ] && [ -x "$DRIVERS_PATH/install_drivers" ]; then
    echo "Found Vivado drivers at $DRIVERS_PATH"
    echo "Run install_vivado_drivers.sh to install them when needed."
fi

echo "Vivado environment setup complete!"
echo "Available aliases:"
echo "  - vivado  : Run Vivado with -nolog -nojournal flags"
echo "  - vstart  : Change to Xilinx directory and launch Vivado"
echo "  - vsyn    : Run Vivado in batch mode (vivado -mode batch -source)"
echo "  - vgui    : Run Vivado in GUI mode"
echo "  - vtcl    : Run Vivado in TCL mode"
echo ""
echo "Helper scripts:"
echo "  - install_vivado_drivers.sh : Install Xilinx hardware drivers"
