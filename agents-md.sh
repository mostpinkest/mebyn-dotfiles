#!/usr/bin/env bash
set -euo pipefail

# Generate AGENTS.md from local Homebrew installation + dotfiles context

if ! command -v brew >/dev/null 2>&1; then
  echo "Error: Homebrew (brew) is not installed or not in PATH" >&2
  exit 1
fi

BREW_VERSION=$(brew --version | head -n1 | awk '{print $2}')

# Resolve repo root (dotfiles dir) from this script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

# Dotfiles inputs (optional)
ZSHRC="$DOTFILES_DIR/.zshrc"
ZPROFILE="$DOTFILES_DIR/.zprofile"
ZIMRC="$DOTFILES_DIR/.zimrc"
ALIASES_FILE="$DOTFILES_DIR/.aliases"
KUBE_ALIASES_FILE="$DOTFILES_DIR/.kubectl_aliases"
GITCONFIG_FILE="$DOTFILES_DIR/.gitconfig"
P10K_FILE="$DOTFILES_DIR/.p10k.zsh"
BREWFILE_PATH="$DOTFILES_DIR/.Brewfile"

# Collect lists (sorted) and counts
FORMULA_LIST=$(brew list --formula | sort || true)
CASK_LIST=$(brew list --cask 2>/dev/null | sort || true)

FORMULA_COUNT=$(printf "%s\n" "$FORMULA_LIST" | sed '/^$/d' | wc -l | tr -d ' ')
CASK_COUNT=$(printf "%s\n" "$CASK_LIST" | sed '/^$/d' | wc -l | tr -d ' ')

OUT_FILE="AGENTS.md"

# Header and overview (with variable expansion, no backticks)
cat > "$OUT_FILE" <<EOF
# Agents Capabilities Reference (Homebrew)

This document summarizes the tools available on this machine via Homebrew and highlights what agents can leverage. It is generated from the current Homebrew installation and is intended as a quick capability map and usage reference.

## Overview

- Homebrew: ${BREW_VERSION}
- Installed formulae: ${FORMULA_COUNT}
- Installed casks: ${CASK_COUNT}
EOF

# Static sections with backticks (no expansion)
cat >> "$OUT_FILE" <<'EOF'

## Key Capabilities

- Developer tooling: `git`, `git-delta`, `gitmoji`, `neovim`, `visual-studio-code` (cask), `cursor` (cask).
- Shell UX and navigation: `bash`, `fzf` (fuzzy find), `ripgrep` (`rg`), `fd`, `bat`, `eza`, `zoxide`, `atuin`, `sd`.
- Languages & runtimes: `node`, `bun`, `python@3.12`, `python@3.13`, `openjdk`, `kotlin`, `luajit`, `pnpm`, `gradle`, `swig`, `uv`.
- Cloud & DevOps: `awscli`, `kubernetes-cli`, `helm`, `docker`, `docker-completion`, `colima`, `lima`, `gcloud-cli`/`google-cloud-sdk` (casks), `kubectl` (via `kubernetes-cli`).
- Containers & virtualization: `docker`, `colima`, `lima` for local Linux VMs/containers.
- JSON, text, and data: `jq`, `simdjson`, `cloc`, `tree-sitter`.
- Networking & security: `wget`, `openssl@3`, `mbedtls`, `gnutls`, `unbound`, `libssh2`, `libssh`, `p11-kit`, `ca-certificates`.
- Media processing: `ffmpeg`, `yt-dlp`, audio/video codecs (`x264`, `x265`, `libvpx`, `opus`, `vorbis`, `webp`, `rav1e`, `svt-av1`, `lame`, `flac`, `theora`).
- Graphics & visualization: `graphviz`, `gdk-pixbuf`, `cairo`, `pango`, image libs (`libpng`, `jpeg-turbo`, `jpeg-xl`, `openjpeg`, `webp`).
- AI/ML & LLM tooling: `ollama` (CLI), `superwhisper` (cask), `chatgpt` (cask UI).
- Desktop productivity (casks): `iterm2`, `maccy`, `rectangle`, `hiddenbar`, `slack`, `obsidian`, `vlc`, `spotify`, `zoom`, `calibre`.

## Tooling Preferences

- Rust / Go powered tools are preferred for efficiency and performance (e.g., `ripgrep`, `fd`, `bat`, `eza`, `zoxide`, `sd`, `fzf`).

## Notable Workflows

- Code search and navigation: combine `ripgrep` + `fd` + `fzf` + `bat`.
- JSON processing: pipe with `jq` (and `sd` for quick regex-safe replacements).
- Containerized development: `colima start` then use `docker` CLI; Kubernetes via `kubectl` and `helm`.
- Frontend/Node: `node`, `pnpm`, `bun` are available for JS/TS projects.
- Python: multiple interpreters (`python3.12`, `python3.13`) and the `uv` package manager.
- Media tooling: `yt-dlp` for downloads and `ffmpeg` for encode/transcode.

## Quick Command Hints

- Git UX: `git -c core.pager=delta` for enhanced diffs via `git-delta`.
- Fuzzy find: `fzf --preview 'bat --style=numbers --color=always {}'`.
- Recursive search: `rg -n "pattern" src/`.
- JSON query: `cat data.json | jq '.items[] | {id, name}'`.
- Start Docker with Colima: `colima start --cpu 4 --memory 8`.
- K8s context list: `kubectl config get-contexts`; Helm chart install: `helm install NAME CHART`.
- Switch shells/tools quickly: `zoxide query` (`z`) and `atuin search` for history.

## Full Inventory
EOF

# Append dynamic context discovered from dotfiles
{
  echo
  echo "## Shell & UX Setup"

  if [[ -f "$ZSHRC" ]]; then
    echo
    echo "- Shell: Zsh with Zimfw framework (see \".zimrc\")."
  fi
  if [[ -f "$P10K_FILE" ]]; then
    echo "- Prompt: Powerlevel10k configured (instant prompt + custom theme)."
  fi

  # List Zim modules if available
  if [[ -f "$ZIMRC" ]]; then
    modules=$(awk '/^zmodule /{print $2}' "$ZIMRC" | tr '\n' ' ' | sed 's/ *$//')
    if [[ -n "${modules:-}" ]]; then
      echo "- Zim modules: ${modules}."
    fi
  fi

  # Atuin presence
  if rg -q "atuin" "$ZIMRC" "$ZSHRC" 2>/dev/null; then
    echo "- History: Atuin enabled (Ctrl-R for fuzzy history search)."
  fi

  # fzf-tab completion
  if rg -q "fzf-tab" "$ZIMRC" 2>/dev/null; then
    echo "- Completion UI: fzf-tab integrated with Zsh completion."
  fi

  # VI mode
  if rg -q "zsh-vi-mode" "$ZIMRC" 2>/dev/null; then
    echo "- Keybindings: zsh-vi-mode active (Esc for normal mode)."
  fi
} >> "$OUT_FILE"

{
  echo
  echo "## Aliases Highlights"

  if [[ -f "$ALIASES_FILE" ]]; then
    # eza overrides
    if rg -q "alias +ls='eza" "$ALIASES_FILE" 2>/dev/null; then
      echo "- ls-family: aliased to eza with icons and grouping."
    fi
    # brewup
    if rg -q "alias +brewup=" "$ALIASES_FILE" 2>/dev/null; then
      echo '- Homebrew: `brewup` updates formulae, casks, and cleans up.'
    fi
    # python/pip
    if rg -q "alias +python=python3" "$ALIASES_FILE" 2>/dev/null; then
      echo '- Python: `python` and `pip` point to Python 3.'
    fi
    # top -> btop
    if rg -q "alias +top='btop'" "$ALIASES_FILE" 2>/dev/null; then
      echo '- System monitor: `top` aliased to `btop`.'
    fi
    # claude
    if rg -q "alias +claude=" "$ALIASES_FILE" 2>/dev/null; then
      echo '- Local AI: `claude` alias available (user-local script).'
    fi
  else
    echo "- Standard aliases present (see ~/.aliases)."
  fi

  # kubectl aliases
  if [[ -f "$KUBE_ALIASES_FILE" ]] && rg -q "kubectl_aliases|kubectl" "$ZPROFILE" 2>/dev/null; then
    echo '- Kubernetes: kubectl shortcut aliases are sourced (e.g., `k`, `kg`, `kd`, `kgs`).'
  fi
} >> "$OUT_FILE"

{
  echo
  echo "## Language Toolchains & Managers"

  # Node via nvm
  if rg -q "zsh-nvm|NVM_LAZY_LOAD" "$ZIMRC" "$ZSHRC" 2>/dev/null; then
    echo '- Node.js: nvm (zsh-nvm) with lazy loading; use `nvm use`.'
  fi
  # Python via uv/pipx
  if [[ -f "$BREWFILE_PATH" ]] && rg -q "^brew +\"uv\"$|^brew +uv$|\buv\b" "$BREWFILE_PATH" 2>/dev/null; then
    echo "- Python: uv package manager installed; multiple Python versions available."
  fi
  if rg -q "\.local/bin" "$ZPROFILE" 2>/dev/null; then
    echo "- Python user tools: pipx path added to PATH."
  fi
  # Go
  if rg -q "GOPATH=.*HOME/go" "$ZSHRC" 2>/dev/null; then
    echo "- Go: GOPATH and \$GOPATH/bin on PATH."
  fi
  # Java helper
  if rg -q "^jdk\(\)" "$ZSHRC" 2>/dev/null; then
    echo '- Java: `jdk <version>` function switches JAVA_HOME (e.g., 17, 21).'
  fi
  # Rustup presence (runtime check)
  if command -v rustup >/dev/null 2>&1; then
    echo '- Rust: rustup installed; use `rustup toolchain` and `cargo`.'
  else
    echo '- Rust: installable via fresh.sh (rustup).'
  fi
} >> "$OUT_FILE"

{
  echo
  echo "## Git Defaults & Helpers"
  if [[ -f "$GITCONFIG_FILE" ]]; then
    if rg -q "pager *= *delta" "$GITCONFIG_FILE" 2>/dev/null; then
      echo "- Paging: delta enabled for diffs and interactive views."
    fi
    if rg -q "rerere\..*enabled *= *true" "$GITCONFIG_FILE" 2>/dev/null; then
      echo "- Rerere: conflict resolution recorded and reused."
    fi
    if rg -q "pull\..*rebase *= *true" "$GITCONFIG_FILE" 2>/dev/null; then
      echo "- Pull behavior: rebase by default; autosquash on rebase."
    fi
    # A few handy aliases if present
    if rg -q "^\s*l\s*=|^\s*gl\s*=|^\s*gds\s*=" "$GITCONFIG_FILE" 2>/dev/null; then
      echo '- Aliases: `gl` graph log, `gds` side-by-side diff, `l` concise log, etc.'
    fi
  else
    echo "- See ~/.gitconfig for delta, rerere, and useful aliases."
  fi
} >> "$OUT_FILE"

{
  echo
  echo "## PATH & Environment"
  if rg -q "/usr/local/sbin" "$ZSHRC" "$ZPROFILE" 2>/dev/null; then
    echo "- PATH includes /usr/local/sbin."
  fi
  if rg -q "brew shellenv" "$ZPROFILE" 2>/dev/null; then
    echo "- Homebrew shellenv is initialized in login shells."
  fi
  if rg -q "BAT_THEME|bat --config-dir" "$ZSHRC" "$DOTFILES_DIR/fresh.sh" 2>/dev/null; then
    echo "- bat: Catppuccin theme configured (via fresh.sh)."
  fi
} >> "$OUT_FILE"

# Inventory headings (with variable expansion)
{
  echo
  echo "### Formulae (${FORMULA_COUNT})"
  echo
  echo '```'
} >> "$OUT_FILE"

# Append formula list and close code block
{
  printf "%s\n" "$FORMULA_LIST"
  echo '```'
} >> "$OUT_FILE"

{
  echo
  echo "### Casks (${CASK_COUNT})"
  echo
  echo '```'
} >> "$OUT_FILE"

# Append cask list and close code block
{
  printf "%s\n" "$CASK_LIST"
  echo '```'
} >> "$OUT_FILE"

cat >> "$OUT_FILE" <<'EOF'

## Maintenance

- Refresh this document after brew changes:
  - Update: `brew update && brew upgrade`
  - List: `brew list --formula | sort` and `brew list --cask | sort`
  - Edit: append new tools and adjust capabilities as needed.

EOF

echo "Wrote ${OUT_FILE} from Homebrew inventory (formulae=${FORMULA_COUNT}, casks=${CASK_COUNT})."
