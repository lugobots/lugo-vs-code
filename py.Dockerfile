FROM lugo-vs

WORKDIR /installing-dir

#COPY --from=builder /usr/local/bin/python3.9 /usr/local/bin/python3.9
#COPY --from=builder /usr/local/lib/python3.9 /usr/local/lib/python3.9
#COPY --from=builder /usr/local/include/python3.9 /usr/local/include/python3.9
#COPY --from=builder /usr/local/lib/libpython3.9* /usr/local/lib/
#COPY --from=builder /usr/local/bin/virtualenv /usr/local/bin/virtualenv
#
#COPY --from=builder /usr/local/lib/python3.9/lib-dynload/_ssl*.so /usr/local/lib/python3.9/lib-dynload/
#COPY --from=builder /usr/local/lib/python3.9/ssl.py /usr/local/lib/python3.9/
RUN sudo apt-get update && sudo apt-get install -y \
    build-essential \
    wget \
    libssl-dev \
    zlib1g-dev \
    libncurses-dev \
    libbz2-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libreadline-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libsqlite3-dev \
    libffi-dev \
    liblzma-dev \
    tk-dev \
    xz-utils \
    uuid-dev \
    llvm \
    curl

# Download and compile Python
ENV PYTHON_VERSION=3.9.19
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar -xzf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make -j$(nproc) && \
    sudo make altinstall && \
    cd / && sudo rm -rf /installing-dir

# Install pip and virtualenv
RUN sudo /usr/local/bin/python3.9 -m ensurepip && \
    sudo /usr/local/bin/python3.9 -m pip install --upgrade pip virtualenv



RUN sudo ln -s /usr/local/bin/python3.9 /usr/local/bin/python
# region Install Python stuff
#RUN sudo apt-get update && sudo apt-get install -y \
#    build-essential \
#    libssl-dev \
#    zlib1g-dev \
#    libncurses-dev \
#    libffi-dev \
#    libsqlite3-dev \
#    libreadline-dev \
#    libbz2-dev \
#    liblzma-dev \
#    uuid-dev \
#    curl \
#    make && \
#    sudo apt-get purge -y python3-minimal python3.11* && \
#    sudo apt-get autoremove -y && \
#    sudo apt-get clean && \
#    sudo rm -rf /usr/lib/python3.11 /usr/lib/python3 /usr/bin/python3 /usr/bin/python3.11 /var/lib/apt/lists/* && \
#    # Download, build and install Python 3.9
#    curl -O https://www.python.org/ftp/python/3.9.18/Python-3.9.18.tgz && \
#    tar -xzf Python-3.9.18.tgz && \
#    cd Python-3.9.18 && \
#    sudo ./configure --enable-optimizations && \
#    sudo make -j"$(nproc)" && \
#    sudo make altinstall && \
#    cd .. && \
#    sudo rm -rf Python-3.9.18 Python-3.9.18.tgz && \
## Create python and python3 shortcuts
#    sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python3.9 1 && \
#    sudo update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.9 1 && \
#    sudo ln -sf /usr/local/bin/python3.9 /usr/bin/python && \
## Remove build dependencies and clean up
#    sudo apt-get purge -y \
#    build-essential \
#    libssl-dev \
#    zlib1g-dev \
#    libncurses-dev \
#    libffi-dev \
#    libsqlite3-dev \
#    libreadline-dev \
#    libbz2-dev \
#    liblzma-dev \
#    uuid-dev && \
#    sudo apt-get autoremove -y && \
#    sudo apt-get clean && \
#    sudo rm -rf /var/lib/apt/lists/* && \
#    sudo curl -sS https://bootstrap.pypa.io/get-pip.py | python3.9 && \
#    python3.9 -m ensurepip && \
#    python3.9 -m pip install --upgrade pip  && \
#    python3.9 -m pip install virtualenv


RUN code-server --install-extension ms-python.python
#    && code-server --install-extension ms-toolsai.jupyter
# endregion





