FROM codercom/code-server:4.100.2-bookworm
WORKDIR /installing-dir
# region Install Python stuff
RUN sudo apt-get update && sudo apt-get install -y \
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


    sudo apt-get purge -y python3-minimal python3.11* && \
    sudo apt-get autoremove -y && \
    sudo apt-get clean && \
    sudo rm -rf /usr/lib/python3.11 /usr/lib/python3 /usr/bin/python3 /usr/bin/python3.11 /var/lib/apt/lists/* && \
# Download, build and install Python 3.9
    curl -O https://www.python.org/ftp/python/3.9.18/Python-3.9.18.tgz && \
    tar -xzf Python-3.9.18.tgz && \
    cd Python-3.9.18 && \
    sudo ./configure --enable-optimizations && \
    sudo make -j"$(nproc)" && \
    sudo make altinstall && \
    cd .. && \
    sudo rm -rf Python-3.9.18 Python-3.9.18.tgz && \
# Create python and python3 shortcuts
    sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python3.9 1 && \
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.9 1 && \
    sudo ln -sf /usr/local/bin/python3.9 /usr/bin/python && \
# Remove build dependencies and clean up
    sudo apt-get purge -y \
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
    sudo apt-get autoremove -y && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/* && \
    sudo curl -sS https://bootstrap.pypa.io/get-pip.py | python3.9 && \
    python3.9 -m ensurepip && \
    python3.9 -m pip install --upgrade pip  && \
    python3.9 -m pip install virtualenv

WORKDIR /home/coder
RUN code-server --install-extension ms-python.python && \
    code-server --install-extension ms-toolsai.jupyter &&  \
    mkdir -p /home/coder/.local/share/code-server/User && \
# endregion
# region Install Go stuff
    code-server --install-extension golang.Go && \
# Install Go 1.21
    wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz && \
    sudo rm go1.21.0.linux-amd64.tar.gz

# Set Go environment
ENV PATH="/usr/local/go/bin:$PATH"

# pre install libs that will be require by Go extensions to enable auto complete
RUN go install golang.org/x/tools/gopls@v0.18.1 && \
    go install honnef.co/go/tools/cmd/staticcheck@v0.6.1

# basic dependencies to make GO projects to load faster
COPY go.mod ./
RUN go mod download
# endregion

# region Nodejs Stuff
# Add NodeSource repo and install Node.js 18
RUN sudo curl -fsSL https://deb.nodesource.com/setup_18.x | sudo bash - \
 && sudo apt-get install -y nodejs \
 && sudo npm install -g npm

# endregion

COPY config.yaml /home/coder/.config/code-server/config.yaml
COPY vs-code-settings.json /home/coder/.local/share/code-server/User/settings.json
#COPY install-dependencies.sh /home/coder/install-dependencies.sh
#COPY tasks.json /home/coder/project/.vscode/tasks.json
COPY entrypoint.sh /entrypoint.sh
RUN sudo chmod +x /entrypoint.sh

WORKDIR /home/coder/project
ENTRYPOINT ["/entrypoint.sh"]



