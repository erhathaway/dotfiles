#!/bin/bash

# to use:
#       1) change file permissions: $ chmod 755 ruby_methods.sh
#       2) add alias to .zshrc: 
#		$ vim ~/.zshrc
#		alias \?rb='/home/ethan/Dropbox/shell/ruby_methods.sh'
#	3) reload .zshrc: $ source ~/.zshrc
#	4) to use: $ ?rb '{}.inject'

# ruby_method - A script to produce documentation for a ruby method
echo "show-doc $1" | pry




