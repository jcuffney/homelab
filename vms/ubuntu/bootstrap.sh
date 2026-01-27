#!/bin/bash
set -euo pipefail

# Bootstrap script for Ubuntu VM
# Installs zsh, configures dotfiles, and sets up shell environment

echo "🚀 Starting VM bootstrap..."

# 1. Update package list
echo "📦 Updating package list..."
apt-get update -qq

# 2. Install zsh and required packages
echo "📦 Installing zsh and dependencies..."
apt-get install -y -qq zsh curl git

# 3. Install starship prompt (optional but recommended)
echo "⭐ Installing starship prompt..."
if command -v starship &> /dev/null; then
    echo "   Starship already installed, skipping..."
else
    curl -sS https://starship.rs/install.sh | sh -s -- -y > /dev/null 2>&1 || {
        echo "   ⚠️  Warning: Failed to install starship, continuing without it..."
    }
fi

# 4. Copy dotfiles to appropriate locations
echo "📝 Configuring dotfiles..."

# Dotfiles are copied by Terraform to /tmp/dotfiles/
DOTFILES_SRC="/tmp/dotfiles"
DOTFILES=(".zshrc" ".zshenv" ".zsh_aliases")

# Function to setup dotfiles for a user
setup_dotfiles_for_user() {
    local user=$1
    local home_dir=$2
    
    for dotfile in "${DOTFILES[@]}"; do
        if [ -f "${DOTFILES_SRC}/${dotfile}" ]; then
            echo "   Copying ${dotfile} for ${user}..."
            cp "${DOTFILES_SRC}/${dotfile}" "${home_dir}/${dotfile}"
            chown "${user}:${user}" "${home_dir}/${dotfile}"
            chmod 644 "${home_dir}/${dotfile}"
        else
            echo "   ⚠️  Warning: ${dotfile} not found in ${DOTFILES_SRC}"
        fi
    done
}

# Setup dotfiles for root
setup_dotfiles_for_user "root" "/root"

# Setup dotfiles for jcuffney user (if home directory exists)
if [ -d "/home/jcuffney" ]; then
    setup_dotfiles_for_user "jcuffney" "/home/jcuffney"
else
    echo "   ⚠️  Warning: /home/jcuffney does not exist yet, dotfiles will be set up on first login"
fi

# 5. Set zsh as default shell for root
echo "🐚 Setting zsh as default shell for root..."
chsh -s /bin/zsh root || {
    echo "   ⚠️  Warning: Failed to change root shell, continuing..."
}

# 6. Set zsh as default shell for jcuffney user
if id "jcuffney" &>/dev/null; then
    echo "🐚 Setting zsh as default shell for jcuffney..."
    chsh -s /bin/zsh jcuffney || {
        echo "   ⚠️  Warning: Failed to change jcuffney shell, continuing..."
    }
else
    echo "   ⚠️  Warning: jcuffney user does not exist yet"
fi

# 7. Cleanup temporary files
echo "🧹 Cleaning up..."
rm -rf "${DOTFILES_SRC}" || true

echo "✅ Bootstrap complete!"
echo ""
echo "Next steps:"
echo "  - SSH into the VM: ssh jcuffney@<vm-ip>"
echo "  - Verify zsh is working: echo \$SHELL"
echo "  - Check starship: starship --version"
