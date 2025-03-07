# Use Ubuntu as the base image
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    nodejs \
    npm \
    wget \
    xz-utils \
    gcc \
    ocaml \
    opam \
    m4 \
    pkg-config \
    libssl-dev \
    libgmp-dev \
    libcurl4-openssl-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Crystal and Kemal
RUN curl -fsSL https://crystal-lang.org/install.sh | bash
RUN install shards


# Install COBOL
RUN apt-get update && apt-get install -y \
    gnucobol \
    && rm -rf /var/lib/apt/lists/*


#try installing libcurl again because it didn't work initally
RUN apt-get update && apt-get install -y libcurl4-openssl-dev
# Set up working directory
WORKDIR /app

# Default command
CMD ["/bin/bash"]