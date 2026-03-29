FROM codercom/code-server:4.100.2-bookworm

USER root
ENV HOME=/home/coder
# region Install Go stuff
#RUN code-server --install-extension golang.Go && \
## Install Go 1.21
#    wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz && \
#    rm -rf /usr/local/go && \
#    sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz && \
#    sudo rm go1.21.0.linux-amd64.tar.gz

# Set Go environment
#ENV PATH="/usr/local/go/bin:$PATH"

# endregion

COPY logger /usr/local/bin/logger
COPY config.yaml /home/coder/.config/code-server/config.yaml
COPY vs-code-settings.json /home/coder/.local/share/code-server/User/settings.json
RUN chown coder -R /home/coder

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER coder

WORKDIR /home/coder/project
ENTRYPOINT ["/entrypoint.sh"]



