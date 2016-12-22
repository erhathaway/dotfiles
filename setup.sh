#!/bin/bash

#################
# General Stuff
#################

printContentLine()
{
	printf "\n   ${1}"
}

getinput()
{
	printf "\n   "
	read "$1"
}

header()
{
	printf "\n********************************************"
	printf "\n"
	printf " $1 "
	printf "\n********************************************"
}

footer()
{
	printContentLine "$1"
}

promptYesToContinue()
{
	printContentLine "Enter YES to continue or any other character(s) to skip it"

}

installing()
{
	printContentLine "...installing"
	footer
}

installed()
{
	printContentLine "...installed!"
	footer
}

changes_applied()
{
	printContentLine "...changes applied"
	footer
}

command_exist()
{
	header "$1"

	if ! hash $2 2>/dev/null; then
		installing
		return 1
	else
		installed
		return 0
	fi
}

pkg_exist()
{
	header "$1"
	local package_name=$(dpkg-query -W --showformat='${Status}\n' $2 2>/dev/null | grep -c "install ok installed")
	if [ "$package_name" -eq 0 ]; then
		installing
		return 1
	else
		installed
		return 0
	fi
}

#################
# Check Programs
#################

# INSTALL SUBLIME 3

install_sublime () 
{
	sudo add-apt-repository ppa:webupd8team/sublime-text-3 &&
	sudo apt-get update &&
	sudo apt-get install sublime-text-installer
}

check_sublime()
{
	local name="Sublime text 3"
	local package=sublime-text-installer

	if ! pkg_exist "$name" "$package"; then
		install_sublime
	fi
}

# INSTALL GDEBI

install_gdebi () 
{
	sudo apt-get update &&
	sudo apt-get install gdebi-core
}

check_gdebi()
{
	local name="gdebi DEB package installer"
	local package=gdebi-core

	if ! pkg_exist "$name" "$package"; then
		install_gdebi
	fi
}

# INSTALL GIT

install_git () 
{
	sudo apt-get update &&
	sudo apt-get install git
}

check_git()
{
	local name="git"
	local package="git"

	if ! pkg_exist "$name" "$package"; then
		install_git
	fi
}

# INSTALL NODE

install_node () 
{
	sudo apt-get update &&
	sudo apt-get install nodejs
}

check_node()
{
	local name="Node JS"
	local package="nodejs"

	if ! pkg_exist "$name" "$package"; then
		install_node
	fi
}

# INSTALL NODE

install_npm () 
{
	sudo apt-get update &&
	sudo apt-get install npm
}

check_npm()
{
	local name="NPM - Node Package Manager"
	local package="npm"

	if ! pkg_exist "$name" "$package"; then
		install_npm
	fi
}

# INSTALL SUPPORTING LIBRARIES 
# Such as build-essential and libssl-dev

install_build () 
{
	sudo apt-get update &&
	sudo apt-get install build-essential
}

install_libssl () 
{
	sudo apt-get update &&
	sudo apt-get install libssl-dev
}

check_support_libraries()
{
	local name="Build essentials"
	local package="build-essential"

	if ! pkg_exist "$name" "$package"; then
		install_build
	fi

	name="libssl (dev)"
	package_a="libssl-dev"

	if ! pkg_exist "$name" "$package"; then
		install_libssl
	fi
}

# INSTALL NVM

install_nvm () 
{
	curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh -o install_nvm.sh &&
	bash install_nvm.sh
}

check_nvm()
{
	local name="NVM - node version manager"
	local package="nvm"
	header "$name"

	if [ ! -d "$NVM_DIR" ] ; then
		installing
		install_nvm
	else
		installed
	fi
}

# INSTALL Angular CLI

install_ngcli () 
{
	npm install -g angular-cli
}

check_ngcli()
{
	local name="Angular CLI"
	local cmd="ng"

	if ! command_exist "$name" "$cmd"; then
		install_ngcli
	fi
}

# INSTALL Terminator

install_terminator () 
{
	sudo apt-get update &&
	sudo apt-get install terminator
}

check_terminator()
{
	local name="Terminator - Terminal manipulator"
	local package="terminator"

	if ! pkg_exist "$name" "$package"; then
		install_terminator
	fi
}

# INSTALL Vim

install_vim () 
{
	sudo apt-get update &&
	sudo apt-get install vim
}

check_vim()
{
	local name="Vim"
	local package="vim"

	if ! pkg_exist "$name" "$package"; then
		install_vim
	fi
}

# INSTALL Zsh

install_zsh () 
{
	sudo apt-get update &&
	sudo apt-get install zsh &&
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

check_zsh()
{
	local name="Zsh and OhMyZsh"
	local package="zsh"

	if ! pkg_exist "$name" "$package"; then
		install_zsh
	fi
}

# INSTALL Google Chrome

install_google_chrome () 
{
	sudo apt-get update &&
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
	sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
	sudo apt-get update &&
	sudo apt-get install google-chrome-stable
}

check_google_chrome()
{
	local name="Google Chrome"
	local package="google-chrome-stable"

	if ! pkg_exist "$name" "$package"; then
		install_google_chrome
	fi
}


#################
# Check Hardware
#################
adjust_trackpoint() 
{
	local directory="/sys/devices/platform/i8042/serio1/serio2"
	local sensitivity_file="${directory}/sensitivity"
	local speed_file="${directory}/speed"

	local name="Trackpoint Adjustment"
	local target_sensitivity="175"
	local target_speed="155"

	local current_sensitivity=$(cat $sensitivity_file)
	local current_speed=$(cat $speed_file)

	header "$name"

	printContentLine "The current trackpoint settings are"
	printContentLine "speed: $current_speed"
	printContentLine "sensitivity: $current_sensitivity"
	printf "\n"
	printContentLine "Do you wish to change these settings?"
	promptYesToContinue
	getinput "choice"

	if [ "$choice" == "YES" ]; then
		local tmpconfig="/etc/tmpfiles.d/trackpoint.conf"
		touch $tmpconfig

		printContentLine "Enter a new speed (recommended is 200) from 0 to 255"
		getinput "speed"
		printContentLine "Enter a new sensitivity (recommended is 255) from 0 to 255"
		getinput "sensitivity"

		local content=$(cat <<-END
			"w ${speed_file} - - - - $speed
			w ${sensitivity_file} - - - - $sensitivity"
			END
			)

		sudo sh -c "echo $content > $tmpconfig"
		sudo sh -c "systemd-tmpfiles --prefix=/sys --create"

		changes_applied
	fi

	footer
}

remove_screen_flicker()
{
	local name="Remove screen flicker"
	header "$name"

	local configfile="/usr/share/X11/xorg.conf.d/20-intel.conf"
	local backupconfigfile="${configfile}.bak"

	printContentLine "This operation overwrites the file $configfile."
	printContentLine "A backupfile is made at $configfile.bak"
	printContentLine "Currently the contents of this file are:\n"
	printContentLine "****** file start ******\n"
	cat $configfile
	printContentLine "****** file end ******"
	printf "\n"
	promptYesToContinue
	getinput "choice"

	if [ "$choice" == "YES" ]; then
		sudo sh -c "touch configfile"
		sudo sh -c "cp $configfile $backupconfigfile"

		local content=$(cat <<-END
		'Section "Device"
		    Identifier "Intel Graphics"
		    Driver "intel"
		    Option "AccelMethod" "sna"
		    Option "TearFree" "true"
		    Option "DRI" "3"
		EndSection'
		END
		)

		sudo sh -c "echo $content > $configfile"
	fi
	footer
}

#################
# Check Environment
#################

create_ssh_key() 
{
	local name="Generate SSH Key"
	header "$name"

	printContentLine "Would you like to generate an SSH key?"
	promptYesToContinue
	getinput "choice"

	if [ "$choice" == "YES" ]; then
		printContentLine "When prompted for a location, just hit the 'enter' key. The default location '~/.ssh/id_rsa' is what you want. Trust me..."
		printContentLine "Enter your email"
		getinput "email"
		ssh-keygen -t rsa -b 4096 -C "$email"
		eval "$(ssh-agent -s)"
		ssh-add ~/.ssh/id_rsa
		
		printContentLine "Don't forget to add your public ssh key '~/.ssh/id_rsa.pub to any servers / apps you want to connect to"
		printContentLine "For example: https://github.com/settings/keys"
	fi
	footer
}

set_git_user()
{
	local name="Set Git User Details"
	header "$name"

	printContentLine "Would you like to set you git user details?"
	promptYesToContinue
	getinput "choice"

	if [ "$choice" == "YES" ]; then
		printContentLine "Enter your email"
		getinput "email"
		git config --global user.email "$email"

		printContentLine "Enter your full name"
		getinput "name"
		git config --global user.name "$name"
	fi
	footer	
}

set_zsh_config()
{
	local name="Customize .zshrc file - aka set zsh config"
	header "$name"

	printContentLine "Would you like to use the custom zsh config file? This will overwrite the existing file..."
	printContentLine "A backupfile is made at ~/.zshrc.bak"
	promptYesToContinue
	getinput "choice"

	if [ "$choice" == "YES" ]; then
		cp ~/.zshrc ~/.zshrc.bak
		cp .zshrc ~ 
	fi
	footer	
}

# #################
# # Run checks and install if needed
# #################

# check_zsh
# check_support_libraries
# check_terminator
# check_vim

# check_sublime
# check_gdebi
# check_git

# check_node
# check_npm
# check_nvm

# check_ngcli
# check_google_chrome

# #################
# # Customize Hardware
# #################

adjust_trackpoint # X1 Carbon, Gen 4 Only?
# remove_screen_flicker # X1 Carbon, Gen 4 w/ Chrome

#################
# Customize Environment
#################

# create_ssh_key
# set_git_user
# set_zsh_config