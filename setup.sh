#!/bin/bash

#################
# General Stuff
#################

header()
{
	printf "\n**"
	printf " $1 "
	printf "**\n"

}

footer()
{
	printf ""
}

installing()
{
	echo "...installing"
	footer
}

installed()
{
	echo "...installed!"
	footer
}

changes_applied()
{
	echo "...changes applied"
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

#################
# Check Hardware
#################
adjust_trackpoint() 
{
	local directory="/sys/devices/platform/i8042/serio1/serio2/"
	local sensitivity_file="${directory}/sensitivity"
	local speed_file="${directory}/speed"

	local name="Trackpoint Adjustment"
	local target_sensitivity="175"
	local target_speed="155"

	local current_sensitivity=$(cat $sensitivity_file)
	local current_speed=$(cat $speed_file)

	header "$name"

	printf "The current trackpoint settings are: \nspeed: $current_speed \nsensitivity: $current_sensitivity"
	
	printf "\n\nEnter a new speed (recommended is 155) or enter the letter 's' to skip\n"
	read speed
	if [ ! "$speed" == "s" ]; then
		sudo sh -c "echo $speed > $speed_file"
		changes_applied
	fi

	printf "\n\nEnter a new sensitivity (recommended is 175) or enter the letter 's' to skip\n"
	read sensitivity
	if [ ! "$sensitivity" == "s" ]; then
		sudo sh -c "echo $sensitivity > $sensitivity_file"
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

	printf "This operation overwrites the file $configfile.\n A backupfile is made, however you may not wish to do this."
	printf "\nCurrently the contents of this file are:\n\n"
	printf "\n****** file start ******\n"
	cat $configfile
	printf "****** file end ******"
	printf "\n\nEnter YES to overwrite the file\n"
	read choice

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
}

#################
# Run checks and install if needed
#################

# check_sublime
# check_gdebi
# check_git
# check_node
# check_npm
# check_support_libraries
# check_nvm
# check_ngcli
# check_terminator
# check_vim

#################
# Customize Hardware
#################

adjust_trackpoint # X1 Carbon, Gen 4 Only?
remove_screen_flicker # X1 Carbon, Gen 4 w/ Chrome 