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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8

RUN mkdir -p /home/user

# Copy scripts
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY test_display.sh /usr/local/bin/test_display.sh
RUN chmod +x /usr/local/bin/test_display.sh

COPY setup_vivado_alias.sh /usr/local/bin/setup_vivado_alias.sh
RUN chmod +x /usr/local/bin/setup_vivado_alias.sh

WORKDIR /home/user

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
