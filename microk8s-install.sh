#!/bin/bash

# Set the username
USERNAME="esteban"
USER_HOME="/home/$USERNAME"

# Ensure the script is executed with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Install MicroK8s from Snap
echo "Installing MicroK8s from Snap..."
snap install microk8s --classic

# Add the user to the microk8s group
echo "Adding $USERNAME to the microk8s group..."
usermod -a -G microk8s $USERNAME
mkdir -p $USER_HOME/.kube
chown -R $USERNAME:$USERNAME $USER_HOME/.kube

# Enable necessary MicroK8s add-ons
microk8s enable dns cert-manager ingress hostpath-storage observability argocd

# Wait for MicroK8s to be ready
echo "Checking MicroK8s status..."
microk8s status --wait-ready

# Set up kubectl alias
echo "Setting up kubectl alias..."
echo "alias kubectl='microk8s kubectl'" >> $USER_HOME/.bash_aliases
sudo snap alias microk8s.kubectl kubectl

# Set up helm alias
echo "Setting up helm alias..."
echo "alias helm='microk8s helm3'" >> $USER_HOME/.bash_aliases

# Provide user with instructions to apply alias
echo "To apply the alias, either restart your terminal or source your .bash_aliases file."
echo "You can now check the nodes and services in your Kubernetes setup:"
echo "microk8s kubectl get nodes"
echo "microk8s kubectl get services"

# Install net-tools package for commands like netstat
apt-get update
apt-get install -y net-tools

# Install build-essential before Homebrew
echo "Installing build-essential..."
apt-get update
apt-get install -y build-essential

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
chown -R $USERNAME:$USERNAME $USER_HOME/.kube

# Install clipboard utilities to copy logs from k9s
apt update
apt-get install -y xclip

# Completion message
echo "Setup complete. Please restart your terminal or run 'source $USER_HOME/.bashrc' to apply the changes."
