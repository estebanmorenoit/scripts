#!/bin/bash

# Prompt for the username
read -p "Enter your username: " USERNAME
USER_HOME="/home/$USERNAME"

# Ensure the script is executed with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

echo "Installing MicroK8s from Snap..."
sudo snap install microk8s --classic

echo "Adding $USERNAME to the microk8s group..."
sudo usermod -a -G microk8s $USERNAME
sudo mkdir -p $USER_HOME/.kube
sudo chown -f -R $USERNAME $USER_HOME/.kube

microk8s enable dns cert-manager ingress hostpath-storage
microk8s enable community
microk8s enable observability

echo "Checking MicroK8s status..."
microk8s status --wait-ready

echo "Setting up kubectl alias..."
echo "alias kubectl='microk8s kubectl'" >> $USER_HOME/.bash_aliases

echo "Setting up helm alias..."
echo "alias helm='microk8s helm3'" >> $USER_HOME/.bash_aliases

echo "To apply the alias, either restart your terminal or source your .bash_aliases file."
echo "You can now check the nodes and services in your Kubernetes setup:"
echo "microk8s kubectl get nodes"
echo "microk8s kubectl get services"

# Install net-tools package for commands like netstat
sudo apt-get update
sudo apt-get install -y net-tools

# Install build-essential before Homebrew
echo "Installing build-essential..."
sudo apt-get update
sudo apt-get install -y build-essential

# Install Homebrew and all pre-requisites as the specified user
echo "Installing Homebrew..."
sudo -u $USERNAME /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Use the full path to the Homebrew binary
HOMEBREW_PATH="/home/linuxbrew/.linuxbrew/bin/brew"

# Add Homebrew to PATH for the specified user
sudo -u $USERNAME bash -c "echo 'eval \$($HOMEBREW_PATH shellenv)' >> /home/$USERNAME/.bashrc"
sudo -u $USERNAME bash -c "eval \$($HOMEBREW_PATH shellenv)"

# Install Homebrew's dependencies and GCC
echo "Installing Homebrew dependencies and GCC..."
sudo -u $USERNAME bash -c "$HOMEBREW_PATH install gcc"

# Install k9s using Homebrew as the specified user
echo "Installing k9s..."
sudo -u $USERNAME bash -c "$HOMEBREW_PATH install derailed/k9s/k9s"

# Add k9s config to enable exec, edit, etc commands
sudo -u $USERNAME bash -c "mkdir -p $USER_HOME/.k9s"
sudo -u $USERNAME bash -c "cat <<EOL > $USER_HOME/.k9s/config.yml
k9s:
  refreshRate: 2
  headless: false
  logoless: false
  noIcons: false
  shells:
    - /bin/bash
    - /bin/sh
    - /busybox/sh
EOL"

# Set up kubeconfig using microk8s
echo "Setting up kubeconfig..."
sudo -u $USERNAME bash -c "mkdir -p $USER_HOME/.kube"
sudo -u $USERNAME bash -c "microk8s config > $USER_HOME/.kube/config"

# Give the user appropriate permissions for microk8s
echo "Adding user to microk8s group..."
sudo chown -R $USERNAME:$USERNAME $USER_HOME/.kube

# Install clipboard utilities to copy logs from k9s
sudo apt update
sudo apt-get install -y xclip

echo "Setup complete."
