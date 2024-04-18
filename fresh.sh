#!/bin/sh

echo "Setting up your Mac..."

for dotfile in `find . -type f -name '.*'`; do
    dfile=$(pwd)/$dotfile
    if [ ! -f $dfile ]; then
      echo "Creating symlink for $dotfile"
      ln -s $dfile $HOME
    fi
done

# Brew setup
if [ -f $HOME/.Brewfile ]; then
  mv $HOME/.Brewfile $HOME/Brewfile
fi

brew bundle install --file=$HOME/Brewfile
brew bundle --force cleanup --file=$HOME/Brewfile

