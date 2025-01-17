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
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Crystal and Kemal
RUN curl -fsSL https://crystal-lang.org/install.sh | bash
RUN crystal init app myapp
RUN cd myapp && echo 'dependencies:\n  kemal:\n    github: kemalcr/kemal' > shard.yml && shards install

# Install COBOL
RUN apt-get update && apt-get install -y \
    gnucobol \
    && rm -rf /var/lib/apt/lists/*

# Install Ur/Web
RUN opam init -y --disable-sandboxing
RUN opam switch create 4.13.1
RUN eval $(opam env)
RUN wget http://www.impredicative.com/ur/urweb-20200209.tgz
RUN tar xzf urweb-20200209.tgz
RUN cd urweb-20200209 && \
    ./configure && \
    make && \
    make install

# Install Pharo (Smalltalk implementation with Seaside)
RUN wget -O - get.pharo.org/64/110+vm | bash
RUN ./pharo Pharo.image eval --save "Metacello new \
    baseline: 'Seaside3'; \
    repository: 'github://SeasideSt/Seaside:master/repository'; \
    load"

# Set up working directory
WORKDIR /app

# Default command
CMD ["/bin/bash"]