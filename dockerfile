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
    && rm -rf /var/lib/apt/lists/*
# Install Nim
RUN curl https://nim-lang.org/choosenim/init.sh -sSf | sh -s -- -y
# Add Nim to PATH
ENV PATH=/root/.nimble/bin:$PATH
#Install Chrystal
RUN curl -fsSL https://crystal-lang.org/install.sh | bash
# Install Mint
RUN git clone https://github.com/mint-lang/mint.git && \
    cd mint && \
    shards install && \
    make && \
    mv ./bin/mint /usr/local/bin/mint && \
    cd .. && \
    rm -rf mint
# Install COBOL
RUN apt-get update && apt-get install -y \
    gnucobol \
    && rm -rf /var/lib/apt/lists/*
# Set up working directory
WORKDIR /app
# Add Nim and Mint to PATH
ENV PATH="/root/.local/share/mint/bin:$PATH"
# Verify installations
RUN nim --version && \
    mint --version && \
    cobc --version
# Default command
CMD ["/bin/bash"]
