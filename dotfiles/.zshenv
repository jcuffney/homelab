# ZSH Environment Variables for Homelab VMs
# Shared across all VMs

# Add common paths to PATH if they exist
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "/usr/local/bin" ] && PATH="/usr/local/bin:$PATH"
