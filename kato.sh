#!/bin/bash

# Script to add user 'kato' with sudo privileges and SSH key authentication
# Run this script with sudo privileges

set -e  # Exit on any error

USERNAME="kato"
SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGzsFMAvAts8MQF22Mz2DLXJ4Pxr3lwF+QD6wgpNmwpSvBF+G5qCsr/iIl5VKFYnzQFDVYWetnc/75cxAV6sf35MLGd+8f3BuIRSP8GIVyum21FYKlu1FeAuvB3zx4nuQ71yJj4u5+miVoYUxyD9qjKf4X9qirktnvqAr4SGzLWn/3bQVdqkXsfDi7RN+u/Qk843h80l2QwSgyCADhArnmafGXafh+NVDg3P/FZ2WX/Y8hrcAIhWrL7iaKlC0MmRivMCVwPvBW28Mn0PRWv8zmlyRuxBv4wWBKpvTIV1Rq5kNa6wrNBxSIA1o1MAN1Zs5bYiR4IyoNp6Ld4YJ1o+Wc2LRloGnS55qOBm4HCVjOLSpT4qY6iuGg/IcndrwG/gHr3N7qmZyjyVz0xzT4mO0CBjmz9a3NlP+3ZsmTHoHEvOQOip/RZ141ob+rhtA8CEtcVuoU+QUsATfPqMqcSOCGaJJOIOvcoa16ckNpOxdtxB0DN8jq7KhX3jeE9tyhrwE= gatete@Batman"

echo "Starting setup for user: $USERNAME"

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run this script with sudo or as root"
    exit 1
fi

# Create user if it doesn't exist
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists"
else
    echo "Creating user $USERNAME..."
    useradd -m -s /bin/bash "$USERNAME"
    echo "User $USERNAME created successfully"
fi

# Add user to sudo group
echo "Adding $USERNAME to sudo group..."
usermod -aG sudo "$USERNAME"

# For CentOS/RHEL systems, also add to wheel group
if [ -f /etc/redhat-release ]; then
    usermod -aG wheel "$USERNAME"
fi

# Set up SSH directory and authorized_keys
echo "Setting up SSH key authentication..."
USER_HOME=$(eval echo ~$USERNAME)
SSH_DIR="$USER_HOME/.ssh"

# Create .ssh directory if it doesn't exist
mkdir -p "$SSH_DIR"

# Add the public key to authorized_keys
echo "$SSH_PUBLIC_KEY" > "$SSH_DIR/authorized_keys"

# Set correct permissions
chmod 700 "$SSH_DIR"
chmod 600 "$SSH_DIR/authorized_keys"
chown -R "$USERNAME:$USERNAME" "$SSH_DIR"

echo "SSH key added successfully"

# Allow passwordless sudo
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
chmod 440 /etc/sudoers.d/$USERNAME

echo ""
echo "=========================================="
echo "Setup completed successfully!"
echo "=========================================="
echo "User: $USERNAME"
echo "Sudo privileges: Enabled (PASSWORDLESS)"
echo "SSH key authentication: Enabled"
echo ""
echo "You can now SSH into the server as:"
echo "ssh $USERNAME@your-server-ip"
echo ""
echo "Note: Password authentication is still enabled."
echo "To disable password authentication, edit /etc/ssh/sshd_config:"
echo "  PasswordAuthentication no"
echo "Then restart SSH: sudo systemctl restart sshd"
echo "=========================================="