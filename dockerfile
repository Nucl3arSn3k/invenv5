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
	dos2unix \
    xz-utils \
    gcc \
    gfortran \
    m4 \
    pkg-config \
    libssl-dev \
    libgmp-dev \
    libcurl4-openssl-dev \
    libsqlite3-dev \
    unzip \
    gdb \
    bubblewrap \
    && rm -rf /var/lib/apt/lists/*

# Install Crystal and Kemal
RUN curl -fsSL https://crystal-lang.org/install.sh | bash




# Install latest Nim with choosenim
RUN curl https://nim-lang.org/choosenim/init.sh -sSf | sh -s -- -y --latest
ENV PATH=/root/.nimble/bin:$PATH


# Install Nim development tools
RUN choosenim stable && \
    nimble install nimlsp -y && \
    choosenim devel
# Set up working directory
WORKDIR /app
# Create an entrypoint wrapper script
RUN echo '#!/bin/bash\ndos2unix /app/entrypoint.sh\nchmod +x /app/entrypoint.sh\nexec /app/entrypoint.sh "$@"' > /entrypoint-wrapper.sh && \
    chmod +x /entrypoint-wrapper.sh
# Default command
CMD ["/bin/bash"]
