# ZSH Configuration for Homelab VMs
# Shared across all VMs

# Source bash aliases for compatibility (if they exist)
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

# Source zsh aliases if they exist
if [ -f ~/.zsh_aliases ]; then
    source ~/.zsh_aliases
fi

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# Basic zsh options
setopt AUTO_CD
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END

# Simple prompt with git branch support
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' on %b'
setopt PROMPT_SUBST
PROMPT='%n@%m %~${vcs_info_msg_0_} $ '

# Enable completion
autoload -Uz compinit
compinit

# Key bindings
bindkey -e  # Emacs key bindings

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
