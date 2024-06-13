#!/bin/sh

echo "Setting up your Mac..."

echo "Creating dotfiles symlink..."
for dotfile in `find . -type f -name '.*'`; do
    if [ ! -f $HOME/$dotfile ]; then
      echo "Creating symlink for $dotfile"
      ln -s $(pwd)/$dotfile $HOME
    fi
done

# Brew setup
if [ -f $HOME/.Brewfile ]; then
  mv $HOME/.Brewfile $HOME/Brewfile
fi

brew bundle install --file=$HOME/Brewfile
brew bundle --force cleanup --file=$HOME/Brewfile

# Ensure pipx is in /bin
pipx ensurepath

# Install bat catppuccin theme
BATCONFIG_DIR=$(bat --config-dir)
if [ ! -f "$BATCONFIG_DIR/themes/Catppuccin Mocha.tmTheme" ]; then
  echo "Installing bat catppuccin theme"
  mkdir -p "$BATCONFIG_DIR/themes"
  wget -P "$BATCONFIG_DIR/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
  bat cache --build
  echo "--theme=\"Catppuccin Mocha\"" >| $(bat --config-file)
fi

# Set screenshot folder location to ~/Documents/Screenshots
defaults write com.apple.screencapture location ~/Documents/Screenshots
killall SystemUIServer

# Install rustup
if ! [ -x "$(command -v rustup)" ] &> /dev/null
then
  curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
fi

