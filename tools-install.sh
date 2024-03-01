#!/bin/bash

# Functions

function generate_ssh_key {
    # generate an ssh key
    read -p ">> Please enter your email: " email
    ssh-keygen -t rsa -b 4096 -C $email

    # start ssh-agent in the background
    eval "$(ssh-agent -s)"

    # create ssh config
    touch ~/.ssh/config
    printf 'Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_rsa' >> ~/.ssh/config
        
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

function setup_system_ssh_keys {
    echo ">> making sure git ssh keys are setup..."
    SSH_KEY_FILE=~/.ssh/id_rsa
    if [ -e $SSH_KEY_FILE ]; then 
	echo "    check."
    else 
	echo "    ssh key needs to be generated. Let's do that now."
	generate_ssh_key
	update_github_ssh
    fi 
}

function configure_git {
    echo ">> making sure git credentials exist..."
    if git config --global -l | grep -q "user.email"; then
	echo "     check"
    else
	read -p ">> Enter the email that you'd like to use for your git config: " email
	git config --global user.email $email

	read -p ">> Enter the username that you'd like to use for your git config: " username
	git config --global user.name $username
    fi
}

function prompt_write_permission {
    echo ">> making sure we have the correct write permissions..."
    sudo chown -R `whoami` /usr/local
    echo "    check."
}

function install_mac_os_tools {
    echo ">> Installing tools for $OSTYPE..."

    # Homebrew
    
    echo ">> installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    #    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/`whoami`/.bash_profile
    eval "$(/opt/homebrew/bin/brew shellenv)"

    echo ">> installing gpg"
    brew install gpg2

    echo ">> installing git"
    brew install git

    echo ">> installing ripgrep"
    brew install ripgrep

    echo ">> installing heroku"
    brew tap heroku/brew && brew install heroku

    # Homebrew Cask

    echo ">> installing emacs"
    brew install --cask emacs

    echo ">> installing slack"
    brew install --cask slack

    echo ">> installing hammerspoon"
    brew install --cask hammerspoon
    open /Applications/Hammerspoon.app

    echo ">> installing iterm2"
    brew install --cask iterm2

    # Ruby

    echo ">> installing rvm"
    gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    \curl -sSL https://get.rvm.io | bash -s stable --ruby
    source $HOME/.rvm/scripts/rvm
    rvm get stable

    echo ">> updating ruby"
    rvm reinstall 3.2.0 --with-openssl-dir=$(brew --prefix openssl) --with-readline-dir=$(brew --prefix readline) --with-libyaml-dir=$(brew --prefix libyaml) --disable-dtrace --disable-docs

    echo ">> installing bundler"
    gem install bundler

    echo ">> installing cocoapods"
    gem install cocoapods

    echo ">> installing fastlane"
    gem install fastlane 
}

function install_gnu_linux_tools {
    echo ">> installing tools for $OSTYPE..."
    echo ""

    echo ">> installing emacs"
    apt-get install emacs

    echo ">> installing ripgrep"
    apt-get install ripgrep
}

# Configs

function install_shared_configs {
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
    rm -rf ~/dotfiles
    mv dotfiles ~
    source ~/dotfiles/bash_config.sh

    echo ">> installing scripts"
    git clone git@github.com:skyefreeman/scripts.git
    rm -rf ~/scripts
    mv scripts ~

    echo ">> installing orgs"
    git clone git@github.com:skyefreeman/org.git
    rm -rf ~/org
    mv org ~

    echo ">> setting up dev directory"
    mkdir ~/dev
}

function install_mac_os_configs {
    install_shared_configs
    
    echo ">> installing hammerspoon config"
    git clone git@github.com:skyefreeman/.hammerspoon.git
    rm -rf ~/.hammerspoon
    mv .hammerspoon ~
}

function install_gnu_linux_configs {
    install_shared_configs
}

# UI Functions

function introduction_animation {
    echo ""
    echo "~~~~~~~~~~~~~~~~~~~"
    echo "~~~~ SkyeTools ~~~~"
    echo "~~~~~~~~~~~~~~~~~~~"
    echo ""
    sleep 1.5
    echo ">> welcome."
    sleep 1.5
    echo ">> ready?"
    sleep 1.5
    echo ">> set?"
    sleep 1.5
    echo ">> go!"
    echo ""
}

##### Script Start #####

introduction_animation

setup_system_ssh_keys

configure_git

INSTALLATION_DIR=/tmp/tools_installation
mkdir $INSTALLATION_DIR
cd $INSTALLATION_DIR

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    install_gnu_linux_tools
    install_gnu_linux_configs
elif [[ "$OSTYPE" == darwin* ]]; then
    install_mac_os_tools
    install_mac_os_configs
else
    echo ">> operating system $OSTYPE is not supported. Aborting."
    exit 0	 	    
fi

cd ~
rm -rf $INSTALLATION_DIR

echo ">> SkyeTools installation complete."

