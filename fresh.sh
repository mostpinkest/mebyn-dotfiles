#!/bin/bash

set -eo pipefail

# Global variables
readonly FONT_DIR="$HOME/Library/Fonts"
readonly SCREENSHOT_DIR="$HOME/Documents/Screenshots"
readonly BREWFILE="$HOME/Brewfile"

# Cleanup function
cleanup() {
    if [ $? -ne 0 ]; then
        echo "❌ Error occurred during setup"
        # Cleanup any partial downloads/installations
        rm -f "$FONT_DIR/MesloLGS NF"*.ttf
    fi
}

trap cleanup EXIT

install_nerd_fonts() {
    mkdir -p "$FONT_DIR"

    # 📦 Font names with normal spaces (much cleaner!)
    local -r fonts=(
        "MesloLGS NF Regular.ttf"
        "MesloLGS NF Bold Italic.ttf"
        "MesloLGS NF Bold.ttf"
        "MesloLGS NF Italic.ttf"
    )

    local -r BASE_URL="https://raw.githubusercontent.com/romkatv/dotfiles-public/master/.local/share/fonts/NerdFonts"

    for font in "${fonts[@]}"; do
        echo "⬇️  Downloading: $font"
        # 🔗 Encode the font name for the URL
        encoded_font=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$font'''))")
        # 📥 Download and save
        if ! curl -fsSL "$BASE_URL/$encoded_font" -o "$FONT_DIR/$font"; then
            echo "❌ Failed to download $font"
            return 1
        fi
    done

    echo "✅ Fonts installed to $FONT_DIR"
}

upgrade_brew_packages() {
    echo "🔄 Updating Homebrew..."
    brew update || { echo "❌ Failed to update Homebrew"; return 1; }
    
    echo "⬆️  Upgrading outdated packages..."
    brew upgrade || { echo "❌ Failed to upgrade packages"; return 1; }
    
    echo "🔍 Upgrading casks..."
    brew upgrade --cask || { echo "❌ Failed to upgrade casks"; return 1; }
    
    # Check for outdated casks that need manual intervention
    local outdated_casks
    outdated_casks=$(brew outdated --cask --greedy --verbose)
    if [ -n "$outdated_casks" ]; then
        echo "📝 Some casks need manual upgrade:"
        echo "$outdated_casks"
    fi
}

setup_homebrew() {
    # 🍺 Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "🛠️  Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "✅ Homebrew is already installed"
    fi

    # Handle Brewfile
    if [ -f "$HOME/.Brewfile" ]; then
        mv "$HOME/.Brewfile" "$BREWFILE"
    fi

    echo "🛠️  Adding Homebrew to PATH"
    echo >> ~/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"

    echo "📦 Installing brew bundle..."
    if ! brew bundle install --file="$BREWFILE" --verbose; then
        echo "❌ Error installing brew bundle"
        exit 1
    fi

    upgrade_brew_packages

    echo "🧹 Performing thorough Homebrew cleanup..."
    if ! brew bundle --force cleanup --file="$BREWFILE"; then
        echo "⚠️ Warning: Brew bundle cleanup failed"
    fi
    # Combine cleanup commands with error checking
    if ! { brew cleanup --prune=all && \
           brew cleanup -s && \
           brew cleanup --prune-prefix; }; then
        echo "⚠️ Warning: Some cleanup operations failed"
    fi
}

create_symlinks() {
    echo "🔗 Creating dotfiles symlink..."
    while IFS= read -r -d '' dotfile; do
        if [ ! -f "$HOME/$(basename "$dotfile")" ]; then
            echo "🔗 Creating symlink for $(basename "$dotfile")"
            ln -s "$(pwd)/$dotfile" "$HOME"
        fi
    done < <(find . -type f -name '.*' -not -name '.gitignore' -print0)
}

setup_bat_theme() {
    local BATCONFIG_DIR
    BATCONFIG_DIR=$(bat --config-dir)
    local theme_file="$BATCONFIG_DIR/themes/Catppuccin Mocha.tmTheme"
    
    if [ ! -f "$theme_file" ]; then
        echo "🎨 Installing bat Catppuccin Mocha theme..."
        mkdir -p "$BATCONFIG_DIR/themes"
        if wget -P "$BATCONFIG_DIR/themes" "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme"; then
            bat cache --build
            echo "--theme=\"Catppuccin Mocha\"" > "$(bat --config-file)"
        else
            echo "❌ Failed to download bat theme"
            return 1
        fi
    fi
}

check_requirements() {
    local required_commands=("curl" "python3" "wget")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "❌ Required command not found: $cmd"
            exit 1
        fi
    done
}

main() {
    # Check if running on macOS
    if [ "$(uname)" != "Darwin" ]; then
        echo "❌ This script is only for macOS"
        exit 1
    fi

    echo "🚀 Setting up your Mac..."

    # Setup steps
    create_symlinks
    setup_homebrew
    install_nerd_fonts

    check_requirements

    # Setup bat theme
    setup_bat_theme

    # Setup screenshots directory
    echo "📸 Setting screenshot folder to $SCREENSHOT_DIR"
    mkdir -p "$SCREENSHOT_DIR"
    defaults write com.apple.screencapture location "$SCREENSHOT_DIR"
    killall SystemUIServer

    # Install rustup if not present
    if ! command -v rustup &> /dev/null; then
        echo "🦀 Installing Rustup..."
        curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
    fi

    echo "✨ Setup completed successfully! 🎉 Enjoy your fresh Mac! 🚀 "
    echo "💻 Remember to restart your terminal for changes to take effect."
}

main "$@"
