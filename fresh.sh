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
