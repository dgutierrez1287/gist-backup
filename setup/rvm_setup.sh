#!/bin/bash

# This bash script will set up an rvm environment for 
# the gist backup ruby script to run in 

## ARGS ##
rubyVersion=$1

function loadRvm() {
	# Load RVM into a shell session *as a function*
	if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then

  	# First try to load from a user install
  	source "$HOME/.rvm/scripts/rvm" > /dev/null

	elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then

  	# Then try to load from a root install
  	source "/usr/local/rvm/scripts/rvm" > /dev/null

	else

  	printf "ERROR: An RVM installation was not found.\n"
	fi
}


## Main ##
loadRvm

rvm version > /dev/null

if [ $? -ne 0 ]; then
	echo "ERROR: rvm does not seem to be installed"
	exit 44
fi

echo "switching to requested ruby version" 

rvm use $rubyVersion > /dev/null

rvm gemset list | grep gistbackup > /dev/null

if [ $? -eq 0 ]; then 
	echo "ERROR: gemset looks like it already exists, please delete and rerun this script"
	exit 42
fi

echo "creating gemset gistbackup"

rvm gemset use gistbackup --create > /dev/null

echo "installing required gems"

gem install net-ping > /dev/null

echo " "
echo "You can now use the rvm wrappers in cron"
echo "this path should be something like;"
echo "<rvm_loc>/wrappers/<ruby_version>@gistbackup/bin/ruby"

exit 0