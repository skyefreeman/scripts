#!/bin/sh

# Functions

function generate_ssh_key {
    # generate an ssh key
    read -p ">> Please enter your email: " email
    ssh-keygen -t rsa -b 4096 -C $email

    # start ssh-agent in the background
    eval "$(ssh-agent -s)"

    # create ssh config
    touch ~/.ssh/config
    echo 'Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_rsa' >> ~/.ssh/config
    
    # add ssh passphrase to the keychain
    ssh-add -K ~/.ssh/id_rsa
}

function update_github_ssh {
    read -p ">> Would you like to add your ssh to github now? (y/n) " answer
    if [ "$answer" = "y" ]; then
	pbcopy < ~/.ssh/id_rsa.pub
	echo ">> ssh public key copied to clipboard"
	echo ">> opening github now..."
	sleep .5
	open https://github.com/settings/ssh/new
	read -n 1 -s -r -p ">> press any key to continue the installation. "
    else
	echo ">> continuing with installation."
    fi
}

function configure_git {
    read -p ">> Enter the email that you'd like to use for your git config: " email
    git config --global user.email $email

    read -p ">> Enter the username that you'd like to use for your git config: " username
    git config --global user.name $username
}

# Ensure that we have the correct write permissions
echo ">> making sure we have the correct write permissions."
sudo chown -R `whoami` /usr/local

# Ensure git is configured
configure_git

# Ensure ssh has been set up for git.

SSH_KEY_FILE=~/.ssh/id_rsa
if [ -e $SSH_KEY_FILE ]; then 
    echo ">> ssh key set up, continuing."
else 
    echo ">> ssh key needs to be generated."
    generate_ssh_key
    update_github_ssh
fi 

# Homebrew

echo ">> beginning tools installation."

echo ">> installing homebrew"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo ">> installing git"
brew install git

echo ">> installing ripgrep"
brew install ripgrep

echo ">> installing heroku"
brew tap heroku/brew && brew install heroku

echo ">> installing vapor"

# Homebrew Cask

echo ">> installing emacs"
brew cask install emacs

echo ">> installing slack"
brew cask install slack

echo ">> installing hammerspoon"
brew cask install hammerspoon
open /Applications/Hammerspoon.app

echo ">> installing iterm2"
brew cask install iterm2

# Ruby

echo ">> installing rvm"
\curl -sSL https://get.rvm.io | bash -s stable --ruby
source $HOME/.rvm/scripts/rvm
rvm get stable

echo ">> updating ruby"
rvm install ruby --latest

echo ">> installing bundler"
gem install bundler

echo ">> installing cocoapods"
gem install cocoapods

echo ">> installing fastlane"
gem install fastlane 

# Personal Configs
echo ">> installing emacs config"
rm -rf ~/.emacs.d
git clone git@github.com:skyefreeman/.emacs.d.git
mv .emacs.d ~

rm ~/.emacs
touch ~/.emacs
echo '(package-initialize)' >> ~/.emacs
echo '(load (expand-file-name "init.el" user-emacs-directory))' >> ~/.emacs

echo ">> installing dotfiles config"
git clone git@github.com:skyefreeman/dotfiles.git
mv dotfiles ~
source ~/dotfiles/bash_config.sh

echo ">> installing hammerspoon config"
git clone git@github.com:skyefreeman/.hammerspoon.git
mv .hammerspoon ~

echo ">> installing scripts"
git clone git@github.com:skyefreeman/scripts.git
mv scripts ~

echo ">> installing orgs"
git clone git@github.com:skyefreeman/org.git
mv org ~

echo ">> setting up dev directory"
mkdir ~/dev

echo ">> finished tools installation."
