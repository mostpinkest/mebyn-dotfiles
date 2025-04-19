#!/bin/sh

install_nerd_fonts() {
  FONT_DIR="$HOME/Library/Fonts"
  mkdir -p "$FONT_DIR"

  # 📦 Font names with normal spaces (much cleaner!)
  fonts=(
    "MesloLGS NF Regular.ttf"
    "MesloLGS NF Bold Italic.ttf"
    "MesloLGS NF Bold.ttf"
    "MesloLGS NF Italic.ttf"
  )

  BASE_URL="https://raw.githubusercontent.com/romkatv/dotfiles-public/master/.local/share/fonts/NerdFonts"

  for font in "${fonts[@]}"; do
    echo "⬇️  Downloading: $font"

    # 🔗 Encode the font name for the URL
    encoded_font=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$font'''))")

    # 📥 Download and save
    curl -fsSL "$BASE_URL/$encoded_font" -o "$FONT_DIR/$font"
  done

  echo "✅ Fonts installed to $FONT_DIR"
}

echo "🚀 Setting up your Mac..."

# 🍺 Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "🛠️  Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✅ Homebrew is already installed"
fi

echo "🔗 Creating dotfiles symlink..."
for dotfile in `find . -type f -name '.*' -not -name '.gitignore'`; do
    if [ ! -f $HOME/$dotfile ]; then
      echo "🔗 Creating symlink for $dotfile"
      ln -s $(pwd)/$dotfile $HOME
    fi
done

# 🖋️ Install fonts
install_nerd_fonts

# 🍻 Brew setup
if [ -f $HOME/.Brewfile ]; then
  mv $HOME/.Brewfile $HOME/Brewfile
fi

echo "📦 Installing brew bundle..."
brew bundle install --file=$HOME/Brewfile --verbose
brew bundle --force cleanup --file=$HOME/Brewfile

# 🎨 Install bat catppuccin theme
BATCONFIG_DIR=$(bat --config-dir)
if [ ! -f "$BATCONFIG_DIR/themes/Catppuccin Mocha.tmTheme" ]; then
  echo "🎨 Installing bat Catppuccin Mocha theme..."
  mkdir -p "$BATCONFIG_DIR/themes"
  wget -P "$BATCONFIG_DIR/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
  bat cache --build
  echo "--theme=\"Catppuccin Mocha\"" >| $(bat --config-file)
fi

# 📸 Set screenshot folder location
echo "📸 Setting screenshot folder to ~/Documents/Screenshots"
defaults write com.apple.screencapture location ~/Documents/Screenshots
killall SystemUIServer

# 🦀 Install rustup
if ! [ -x "$(command -v rustup)" ] &> /dev/null
then
  echo "🦀 Installing Rustup..."
  curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
fi
