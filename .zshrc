# Enable Powerlevel10k instant prompt. Keep this at the very top of ~/.zshrc.
# Initialization requiring user input should go above this block.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# Autosuggestions
# Leave MANUAL_REBIND enabled only if autosuggestions is the last interactive module (it is).
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_USE_ASYNC=1

# Syntax highlighting
# Using fast-syntax-highlighting; ZSH_HIGHLIGHT_* applies to zsh-users/zsh-syntax-highlighting.
# If switching back to zsh-users, uncomment and adjust as needed.
# ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
# typeset -A ZSH_HIGHLIGHT_STYLES
# ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

# ------------------
# Initialize modules
# ------------------
# Ensure terminfo and complist are available before plugin init (fzf-tab)
zmodload -F zsh/terminfo +p:terminfo
zmodload zsh/complist

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
# }}} End configuration added by Zim install

# ZSH profiler
# zmodload zsh/zprof

##############################################################################
# History Configuration
##############################################################################
# Atuin handles interactive history search; remove omz_history aliases

: ${HISTFILE:="$HOME/.zsh_history"}
: ${HISTSIZE:=50000}
: ${SAVEHIST:=10000}

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

# --- fzf-tab: lean, robust config ---
# Keep fzf-tab isolated from global FZF_DEFAULT_OPTS (recommended)
zstyle ':fzf-tab:*' use-fzf-default-opts no  # see README warning

# Modern FZF UI flags; put preview-window here (fzf-tab doesn't have a separate style)
zstyle ':fzf-tab:*' fzf-flags --ansi --height=60% --reverse --border --info=inline-right --preview-window=right:60%,wrap

# Using --border? Add pad so the prompt/layout doesn't get cramped
zstyle ':fzf-tab:*' fzf-pad 4

# If LS_COLORS is empty (common on macOS), fall back to a sane theme
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' menu no
if [[ -n ${LS_COLORS:-} ]]; then
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
else
  zstyle ':completion:*' list-colors 'di=34:ln=36:so=32:bd=33:cd=33:or=31:mi=41;37:ex=35'
fi

# Preview layout & navigation
zstyle ':fzf-tab:*' switch-group '<' '>'

# (fzf extended-search is on by default; no extra setting needed)

# Matchers: prefix → case-insensitive word → case-insensitive substring
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Z}' \
  'm:{a-z}={A-Z} r:|[._-]=* r:|=*' \
  'm:{a-z}={A-Z} l:|=* r:|=*'

# Useful previews (with fallbacks)
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'if (( $+commands[eza] )); then eza -1 --group-directories-first --color=always --icons $realpath; else ls -1 -GF $realpath; fi'

zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview '
  if [[ $group == "[process ID]" ]]; then
    case "$(uname -s)" in
      Darwin) ps -p $word -o pid,pcpu,pmem,command ;;
      *)      ps -p $word -o pid,pcpu,pmem,command --no-headers ;;
    esac
  fi'

zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
  'case "$group" in
    "modified file") git diff -- $word | delta || git diff -- $word ;;
    "recent commit object name") git show --color=always $word | delta || git show --color=always $word ;;
    *) git log --color=always --oneline --decorate -n 40 -- $word ;;
  esac'

# --- alias cache for fzf previews (keeps child shells in sync) ---
alias-cache-update() {
  local P=$'\x1F' F=$'\x1E'
  local out=() k
  for k in ${(k)aliases}; do
    out+=("${k}${F}${aliases[$k]}")
  done
  export FZFTAB_ALIAS_CACHE="${(j:$P:)out}"
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd alias-cache-update
alias()   { builtin alias   "$@"; alias-cache-update; }
unalias() { builtin unalias "$@"; alias-cache-update; }
# initialize once
alias-cache-update

zstyle ':fzf-tab:complete:-command-:*' fzf-preview '
  emulate -L zsh

  # Rehydrate alias map from exported cache
  local P F; P=$(printf "\\x1F"); F=$(printf "\\x1E")
  local -A MAP
  local kv k v
  for kv in "${(@s:$P:)FZFTAB_ALIAS_CACHE}"; do
    k=${kv%%$F*}
    v=${kv#*$F}
    [[ -n $k ]] && MAP[$k]=$v
  done

  # If the current item is a file, preview it nicely
  if [[ ${(Q)group} == "[file]" && -n ${(Q)realpath} ]]; then
    if [[ -d ${(Q)realpath} ]]; then
      (( $+commands[eza] )) && eza --tree --level=2 --icons --color=always ${(Q)realpath} || ls -GF ${(Q)realpath}
      return
    fi
    mime=$(file -bL --mime-type -- ${(Q)realpath}); category=${mime%%/*}
    if [[ $category == text ]]; then
      (( $+commands[bat] )) && bat --color=always --style=plain --paging=never ${(Q)realpath} || sed -n "1,200p" -- ${(Q)realpath}
      return
    fi
  fi
  if [[ -n ${MAP[${(Q)word}]-} ]]; then
    print -r -- ${MAP[${(Q)word}]}
    return
  fi

  # TLDR (tldr/tlrc) only if page exists; avoid noisy page-not-found output
  if command -v tldr >/dev/null 2>&1; then
    if tldr -a 2>/dev/null | grep -Fxq -- "$word"; then
      tldr --color always "$word"
      return
    fi
  fi

  if man "$word" >/dev/null 2>&1; then
    MANWIDTH=$FZF_PREVIEW_COLUMNS man "$word"
  else
    whence -p "$word" || :
  fi
'