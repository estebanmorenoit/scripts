#!/bin/bash

# Prompt for the username
read -p "Enter your username: " USERNAME
USER_HOME="/home/$USERNAME"

# Ensure the script is executed with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Stop MicroK8s
echo "Stopping MicroK8s..."
sudo microk8s.stop

# Remove MicroK8s
echo "Removing MicroK8s..."
sudo snap remove microk8s

# Remove residual files and directories
echo "Removing residual files and directories..."
sudo rm -rf /var/snap/microk8s
sudo rm -rf /var/snap/microk8s/common/var/lib/containerd
sudo rm -rf /var/snap/microk8s/common/run
sudo rm -rf $USER_HOME/.kube

# Remove user from microk8s group
echo "Removing $USERNAME from microk8s group..."
sudo gpasswd -d $USERNAME microk8s

# Optionally, remove the group if it is no longer needed
if ! grep -q microk8s /etc/group; then
    echo "Removing microk8s group..."
    sudo groupdel microk8s
fi

# Remove kubectl alias
echo "Removing kubectl alias..."
sed -i '/alias kubectl=/d' $USER_HOME/.bash_aliases

# Notify the user to restart the terminal or source the .bash_aliases file
echo "To apply changes, either restart your terminal or source your .bash_aliases file."
sudo -u $USERNAME bash -c "source $USER_HOME/.bash_aliases"

echo "MicroK8s has been successfully uninstalled and cleaned up."

# Optional: remove any specific configurations related to MicroK8s in your home directory
echo "Removing any additional MicroK8s configurations..."
sudo rm -rf $USER_HOME/.microk8s

echo "Uninstallation complete."
