FROM lugo-vs

# Install Go 1.21
ENV GO_VERSION=1.21.13
RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    | sudo tar -C /usr/local -xz \
    && sudo ln -s /usr/local/go/bin/go /usr/local/bin/go \
    && sudo ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

# Set Go environment
ENV GOPATH=/home/coder/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH


# Install Go tools required by VS Code
RUN go install golang.org/x/tools/gopls@latest \
    && go install github.com/go-delve/delve/cmd/dlv@latest \
    && go install honnef.co/go/tools/cmd/staticcheck@latest \
    && go install golang.org/x/tools/cmd/goimports@latest

# Ensure Go tools are available in PATH
ENV PATH=$PATH:$GOPATH/bin

# Install VS Code Go extension
RUN code-server --install-extension golang.go

# Default workdir
WORKDIR /home/coder/project

ENTRYPOINT ["/entrypoint.sh"]