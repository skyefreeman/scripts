#!/bin/sh

# Homebrew

echo "Beginning tools installation."

echo "Installing Homebrew"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "Installing Git"
brew install git

echo "Installing Emacs"
brew install emacs --with-cocoa

echo "Installing ripgrep"
brew install ripgrep

# Homebrew Cask

echo "Installing brew-cask"
brew tap caskroom/cask
brew install brew-cask
brew tap caskroom/versions

echo "Installing Slack"
brew cask install slack

# Ruby

echo "Installing RVM"
\curl -sSL https://get.rvm.io | bash -s stable --ruby

echo "Installing Bundler"
sudo gem install bundler

echo "Installing Cocoapods"
sudo gem install cocoapods

echo "Installing Fastlane"
sudo gem install fastlane 

#todo: move this to homebrew
echo "Installing Hammerspoon"
curl -O -J -L https://github.com/Hammerspoon/hammerspoon/releases/download/0.9.46/Hammerspoon-0.9.46.zip
open Hammerspoon*

echo "Installing iTerm"
curl -O -J -L https://iterm2.com/downloads/stable/iTerm2-3_0_12.zip
open iTerm*

# Personal Configs
echo "Installing emacs config"
git clone git@github.com:skyefreeman/.emacs.d.git
mv .emacs.d ~/.emacs.d

touch ~/.emacs
echo '(package-initialize)' >> ~/.emacs
echo '(load (expand-file-name "init.el" user-emacs-directory))' >> ~/.emacs

echo "Installing dotfiles config"
git clone git@github.com:skyefreeman/dotfiles.git
mv dotfiles ~/dotfiles
source ~/dotfiles/bash_config.sh

echo "Installing hammerspoon config"
git clone git@github.com:skyefreeman/.hammerspoon.git
mv ~/.hammerspoon/

echo "Installing scripts"
git clone git@github.com:skyefreeman/scripts.git
mv scripts ~/scripts

echo "Installing orgs"
git clone git@github.com:skyefreeman/org.git
mv org ~/org

echo "Cleaning up..."
rm *.zip
mv *.app /Applications

echo "Finished tools installation."
