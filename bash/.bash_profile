# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"


# Added by Antigravity CLI installer
export PATH="/Users/mbchavezz/.local/bin:$PATH"
