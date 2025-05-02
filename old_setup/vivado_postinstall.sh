#!/usr/bin/env bash

VIVADO_VERSION="2024.1"
echo " " >> "$HOME/.bashrc"
echo "export VIVADO_VERSION=\"$VIVADO_VERSION\"" >> "$HOME/.bashrc"
echo "export VIVADO_HOME=\"/tools/Xilinx/Vivado/\$VIVADO_VERSION/\"" >> "$HOME/.bashrc"
echo "export PATH=\$PATH:\"/tools/Xilinx/xic/\"" >> "$HOME/.bashrc"
echo "export PATH=\$PATH:\"/tools/Xilinx/Vivado/\$VIVADO_VERSION/bin\"" >> "$HOME/.bashrc"
echo "alias vivado='vivado -nolog -nojournal'" >> "$HOME/.bashrc"
echo " " >> "$HOME/.bashrc"

sudo apt install libtinfo-dev
sudo apt install libncurses5-dev

SYMLINK="/lib/x86_64-linux-gnu/libtinfo.so.5"
TARGET="/lib/x86_64-linux-gnu/libtinfo.so.6"

if [ ! -e "$SYMLINK" ]; then
    sudo ln -s "$TARGET" "$SYMLINK"
    echo "Symlink created: $SYMLINK -> $TARGET"
else
    echo "Symlink already exists: $SYMLINK"
fi

cd "/tools/Xilinx/Vivado/$VIVADO_VERSION/data/xicom/cable_drivers/lin64/install_script/install_drivers/"
sudo ./install_drivers
