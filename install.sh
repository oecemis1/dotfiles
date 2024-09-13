#!/usr/bin/env bash

FONTS_DIR="$HOME/.local/share/fonts"

function core(){ 
	sudo apt install curl
	sudo apt install unrar
	sudo apt install zip
	sudo apt install unarchiver
	sudo apt install xsel
	sudo apt install wget
	curl -sS https://starship.rs/install.sh | sh
	echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
	curl -L https://nixos.org/nix/install | sh -s -- --daemon
}

function gnome(){
	sudo apt install gnome-tweaks
	sudo apt install chrome-gnome-shell
	cat gterminal.preferences | dconf load /org/gnome/terminal/
}

function cleanup(){
	sudo apt remove yelp
	sudo apt remove gnome-text-editor
	sudo apt remove gnome-system-monitor
	sudo snap remove firefox
}

function fonts(){
	if [ ! -d "$FONTS_DIR" ]; then
		echo "Creating fonts directory..."
		mkdir -p "$FONTS_DIR"
	else
		echo "Fonts directory already exists"
	fi
	wget -O "$HOME/Downloads/Noto.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Noto.zip
	mkdir "$HOME/Downloads/Noto"
	wget -O "$HOME/Downloads/JetBrainsMono-.zip" https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip
	mkdir "$HOME/Downloads/JetBrainsMono"
	unzip "$HOME/Downloads/JetBrainsMono-*" -d "$HOME/Downloads/JetBrainsMono"
	unzip "$HOME/Downloads/Noto*" -d "$HOME/Downloads/Noto"
	mv "$HOME/Downloads/Noto" "$HOME/.local/share/fonts/"
	mv "$HOME/Downloads/JetBrainsMono" "$HOME/.local/share/fonts/"
	rm "$HOME/Downloads/Noto.zip"
	rm "$HOME/Downloads/JetBrainsMono-.zip"
}

# core
# fonts
gnome
# cleanup
