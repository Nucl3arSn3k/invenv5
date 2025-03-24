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
    dune \
    m4 \
    pkg-config \
    libssl-dev \
    libgmp-dev \
    libcurl4-openssl-dev \
    unzip \
    gdb \
    bubblewrap \
    && rm -rf /var/lib/apt/lists/*

# Install Crystal and Kemal
RUN curl -fsSL https://crystal-lang.org/install.sh | bash


# Install COBOL
RUN apt-get update && apt-get install -y \
    gnucobol \
    && rm -rf /var/lib/apt/lists/*

# Initialize OPAM and install OCaml development tools
RUN opam init --disable-sandboxing --no-setup --yes && \
    opam switch create 4.14.1 && \
    eval $(opam env) && \
    opam install -y \
    ocaml-lsp-server \
    ocamlformat \
    utop \
    merlin \
    odoc \
    ocp-indent

# Add OPAM environment to PATH and make it available in all shells
RUN echo 'eval $(opam env)' >> ~/.bashrc

# Set up working directory
WORKDIR /app

# Default command
CMD ["/bin/bash"]
