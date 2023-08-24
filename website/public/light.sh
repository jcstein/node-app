#!/bin/bash
set -e

echo ""
echo "🔍  Determining OS and architecture..."

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

if [[ "$ARCH" == "x86_64" ]]; then
    ARCH="amd64"
elif [[ "$ARCH" == "arm64" ]] || [[ "$ARCH" == "aarch64" ]]; then
    ARCH="arm64"
fi

echo "💻  OS: $OS"
echo "🏗️  ARCH: $ARCH"

# Define the version of Golang and Celestia Node you want to install
GOLANG_VERSION="1.20.2"
CELESTIA_NODE_VERSION="v0.11.0-rc8"

echo "🐹  Golang version: $GOLANG_VERSION"
echo "🌌  Celestia Node version: $CELESTIA_NODE_VERSION"

# Install Golang
echo "⬇️  Installing Golang..."
cd $HOME
if [[ "$OS" == "darwin" ]]; then
    wget -q "https://golang.org/dl/go$GOLANG_VERSION.darwin-$ARCH.tar.gz"
    echo "🔑  Admin access is required to install Golang. Please enter your password if prompted."
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go$GOLANG_VERSION.darwin-$ARCH.tar.gz" > /dev/null
    rm "go$GOLANG_VERSION.darwin-$ARCH.tar.gz"
else
    wget -q "https://golang.org/dl/go$GOLANG_VERSION.linux-$ARCH.tar.gz"
    echo "🔑  Admin access is required to install Golang. Please enter your password if prompted."
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go$GOLANG_VERSION.linux-$ARCH.tar.gz" > /dev/null
    rm "go$GOLANG_VERSION.linux-$ARCH.tar.gz"
fi

echo "✅  Golang installed."

# Install Celestia Node
echo "⬇️  Installing Celestia Node..."
cd $HOME
rm -rf celestia-node
git clone -q https://github.com/celestiaorg/celestia-node.git
cd celestia-node/
git checkout -q tags/$CELESTIA_NODE_VERSION

echo "🔨  Building Celestia..."
make build > /dev/null

if [[ "$OS" == "darwin" ]]; then
    echo "🔧  Installing Celestia..."
    make go-install > /dev/null
else
    echo "🔧  Installing Celestia..."
    echo "🔑  Admin access is required to install Celestia. Please enter your password if prompted."
    make install > /dev/null
fi

echo "🔑  Building cel-key..."
make cel-key > /dev/null

echo "✅  Celestia Node installed."

# Instantiate a Celestia light node
echo "🚀  Instantiating a Celestia light node..."
celestia light init --p2p.network arabica > /dev/null

echo "🎉  Installation complete! You can now use Celestia Node from your terminal."

# Start the Celestia light node
echo "🚀  Starting Celestia light node..."
celestia light start --p2p.network arabica
echo ""