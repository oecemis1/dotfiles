FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Update and install minimal required packages
RUN apt-get update && apt-get -y upgrade && apt-get install -y \
    build-essential \
    default-jre \
    xorg \
    libxrender-dev \
    libxtst-dev \
    wget \
    vim \
    sudo \
    locales \
    gosu \
    # Additional packages for graphics and DBus
    dbus-x11 \
    libdbus-1-3 \
    libgl1-mesa-dri \
    libglu1-mesa \
    libglx-mesa0 \
    mesa-utils \
    libegl1 \
    libegl-mesa0 \
    libglvnd0 \
    # Wayland support
    libwayland-client0 \
    libwayland-cursor0 \
    libwayland-egl1 \
    libxkbcommon0 \
    # Additional dependencies for Electron apps
    libasound2t64 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcairo2 \
    libcups2 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libx11-xcb1 \
    libxcb-dri3-0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    ripgrep \
    git \
    curl \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8

# Copy scripts
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY test_display.sh /usr/local/bin/test_display.sh
RUN chmod +x /usr/local/bin/test_display.sh

COPY setup_vivado_alias.sh /usr/local/bin/setup_vivado_alias.sh
RUN chmod +x /usr/local/bin/setup_vivado_alias.sh

# Add new script for Vitis setup
COPY setup_vitis_alias.sh /usr/local/bin/setup_vitis_alias.sh
RUN chmod +x /usr/local/bin/setup_vitis_alias.sh

WORKDIR /home/ubuntu

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
