# Lazy load NVM
export NVM_LAZY_LOAD=true

export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";

# Define aliases
source ~/.aliases
source ~/.kubectl_aliases

# Created by `pipx` on 2024-04-29 10:09:34
export PATH="$PATH:/Users/mesy/.local/bin"
