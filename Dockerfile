FROM lugo-vs

USER root
ARG TARGETARCH

WORKDIR /installing-dir
# region Install Python stuff
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libncurses-dev \
    libffi-dev \
    libsqlite3-dev \
    libreadline-dev \
    libbz2-dev \
    liblzma-dev \
    uuid-dev \
    curl \
    make && \
    apt-get purge -y python3-minimal python3.11* && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /usr/lib/python3.11 /usr/lib/python3 /usr/bin/python3 /usr/bin/python3.11 /var/lib/apt/lists/* && \
# Download, build and install Python 3.9
    curl -O https://www.python.org/ftp/python/3.9.18/Python-3.9.18.tgz && \
    tar -xzf Python-3.9.18.tgz && \
    cd Python-3.9.18 && \
    ./configure --enable-optimizations && \
    make -j"$(nproc)" && \
    make altinstall && \
    cd .. && \
    rm -rf Python-3.9.18 Python-3.9.18.tgz && \
# Create python and python3 shortcuts
    update-alternatives --install /usr/bin/python python /usr/local/bin/python3.9 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.9 1 && \
    ln -sf /usr/local/bin/python3.9 /usr/bin/python && \
# Remove build dependencies and clean up
    apt-get purge -y \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libncurses-dev \
    libffi-dev \
    libsqlite3-dev \
    libreadline-dev \
    libbz2-dev \
    liblzma-dev \
    uuid-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.9 && \
    python3.9 -m ensurepip && \
    python3.9 -m pip install --upgrade pip  && \
    python3.9 -m pip install virtualenv

USER coder
WORKDIR /home/coder
RUN code-server --install-extension ms-python.python && \
    code-server --install-extension ms-toolsai.jupyter &&  \
    mkdir -p /home/coder/.local/share/code-server/User && \
# endregion
# region Install Go stuff
    code-server --install-extension golang.Go && \
# Install Go 1.21
    mkdir -p /tmp/go-install

USER root
RUN case "$TARGETARCH" in \
      amd64) GO_ARCH="amd64" ;; \
      arm64) GO_ARCH="arm64" ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac && \
    wget "https://go.dev/dl/go1.21.0.linux-${GO_ARCH}.tar.gz" -O /tmp/go-install/go.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf /tmp/go-install/go.tar.gz && \
    rm -rf /tmp/go-install


# Set Go environment
ENV PATH="/usr/local/go/bin:$PATH"

USER coder
RUN go install golang.org/x/tools/gopls@v0.21.0 \
    && go install github.com/go-delve/delve/cmd/dlv@latest \
    && go install honnef.co/go/tools/cmd/staticcheck@latest \
    && go install golang.org/x/tools/cmd/goimports@latest


# endregion

# region Nodejs Stuff
# Add NodeSource repo and install Node.js 18
USER root
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
 && apt-get install -y nodejs \
 && npm install -g npm

# endregion

COPY config.yaml /home/coder/.config/code-server/config.yaml
COPY vs-code-settings.json /home/coder/.local/share/code-server/User/settings.json
RUN chown coder /home/coder/.local/share/code-server/User/settings.json

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER coder
WORKDIR /home/coder/project
ENTRYPOINT ["/entrypoint.sh"]



