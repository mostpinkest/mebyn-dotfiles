# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#

# -----------------
# Zsh configuration
# -----------------

#
# History
#

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -e

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# -----------------
# Zim configuration
# -----------------

# Use degit instead of git as the default tool to install and update modules.
#zstyle ':zim:zmodule' use 'degit'

# --------------------
# Module configuration
# --------------------

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
#zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
zstyle ':zim:termtitle' format '%1~'

# Disable automatic widget re-binding on each precmd. This can be set when
# zsh-users/zsh-autosuggestions is the last module in your ~/.zimrc.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_USE_ASYNC=1

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

# ------------------
# Initialize modules
# ------------------
export NVM_LAZY_LOAD=true
ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
if [[ -r ${ZIM_HOME}/init.zsh ]]; then
  source ${ZIM_HOME}/init.zsh
else
  print -r -- "Zim not installed. Run: curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh"
fi

# ------------------------------
# Post-init module configuration
# ------------------------------

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

zmodload -F zsh/terminfo +p:terminfo
# }}} End configuration added by Zim install

# ZSH profiler
# zmodload zsh/zprof

##############################################################################
# History Configuration
##############################################################################
# Atuin handles interactive history search; remove omz_history aliases

[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
[ "$HISTSIZE" -lt 50000 ] && HISTSIZE=50000
[ "$SAVEHIST" -lt 10000 ] && SAVEHIST=10000

setopt    appendhistory          # Append history to the history file (no overwriting)
setopt    extended_history       # record timestamp of command in HISTFILE
setopt    hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt    hist_ignore_dups       # ignore duplicated commands history list
setopt    hist_ignore_space      # ignore commands that start with space
setopt    hist_verify            # show command with history expansion to user before running it
setopt    sharehistory           # Share history across terminals
setopt    incappendhistory       # Immediately append to the history file, not just when a term is killed
setopt    hist_save_no_dups      # don't write dupes to history file
setopt    hist_find_no_dups      # skip dupes when searching history
setopt    hist_save_no_dups      # don't write dupes to history file
setopt    hist_find_no_dups      # skip dupes when searching history

# Executables
export EXECPATH=$HOME/bin
export PATH=$PATH:$EXECPATH

# Golang
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# AdoptOpenJDK change java version
jdk() {
  version=$1
  export JAVA_HOME=$(/usr/libexec/java_home -v"$version");
  java -version
}

# Configure directory listing colors
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ZVM Lazy key binding (leave Ctrl-R free for Atuin)
function zvm_after_lazy_keybindings() {
  zvm_bindkey vicmd '^[[A' history-substring-search-up
  zvm_bindkey vicmd '^[[B' history-substring-search-down
}

# autoload -U +X bashcompinit && bashcompinit
# complete -o nospace -C /usr/local/bin/terraform terraform
export PATH="/usr/local/sbin:$PATH"

# Pyenv configuration
# alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'
# export PYENV_ROOT="$HOME/.pyenv"
# [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

# .gitignore Generator
function gi() { curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/$@ ;}

# bat command Theme
BAT_THEME="base16-256"

# END Zsh Profiler
# zprof

# (pipx PATH is handled in ~/.zprofile)

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# zsh-nvm handles NVM loading (lazy); no manual sourcing here

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Atuin: modern history search and sync
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

# zoxide: smarter cd
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# direnv: per-project envs
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Completion quality tweaks (fzf-tab compatible)
zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh_cache"
zstyle ':fzf-tab:*' switch-group '<' '>'

# fzf defaults and completion (leave Ctrl-R to Atuin)
if command -v fzf >/dev/null 2>&1; then
  # Use fd if available, else ripgrep, else find
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  elif command -v rg >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git/*'"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  else
    export FZF_DEFAULT_COMMAND="find . -type f -not -path '*/.git/*'"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
  # Only source fzf completion, avoid key-bindings to keep Ctrl-R for Atuin
  if command -v brew >/dev/null 2>&1; then
    __FZF_COMPLETION="$(brew --prefix 2>/dev/null)/opt/fzf/shell/completion.zsh"
    [[ -r $__FZF_COMPLETION ]] && source "$__FZF_COMPLETION"
    unset __FZF_COMPLETION
  fi
fi

# fzf-tab previews
zstyle ':fzf-tab:complete:*' fzf-preview 'bat --style=numbers --color=always --line-range=:200 -- $realpath 2>/dev/null || ls -lah ${realpath:h}'

# Handy context-aware previews
# Directories (cd): show detailed listing
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -lah --color=always --group-directories-first $realpath 2>/dev/null || ls -lah $realpath'
# git branches/tags (checkout/switch): show recent commit graph
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 'git --no-pager log --graph --decorate --oneline --color=always -n 30 -- $word'
zstyle ':fzf-tab:complete:git-switch:*'   fzf-preview 'git --no-pager log --graph --decorate --oneline --color=always -n 30 -- $word'
# git show objects: show patch/stat
zstyle ':fzf-tab:complete:git-show:*'     fzf-preview 'git --no-pager show --color=always --stat --patch $word'
# git file args (add/restore): show diff for file
zstyle ':fzf-tab:complete:git-add:*'      fzf-preview 'git --no-pager diff --color=always -- $realpath'
zstyle ':fzf-tab:complete:git-restore:*'  fzf-preview 'git --no-pager diff --color=always -- $realpath'
# kill: preview process details
zstyle ':fzf-tab:complete:kill:*'         fzf-preview 'ps -p $word -o pid,ppid,stat,etime,%cpu,%mem,command -ww --no-headers'
