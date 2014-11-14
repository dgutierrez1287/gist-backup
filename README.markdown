Gist-Backup
===========

Table of Contents
-----------------
1.  [Overview](#overview) 
2.  [Install](#install)
3.  [Setup](#setup)
4.  [Usage](#usage)
6.  [Development - Guide for contributing](#development)
7.  [Disclaimer](#disclaimer)
8.  [Contributors - List of module contributors](#contributors)

Overview
---------------
This is a ruby script meant to work with rvm and cron to back up personal system config files (example: bashrc) to a private gist. This script can be put into cron to allow you to run it on a timed basis. This can also be used with many different organization systems, there can be multiple files per gist or a single file per gist.

Install
---------------
To install this you can, check it out to whereever you typically install software and add the bin folder of the checkout to your path.

Setup
---------------
This setup guide assumes that you already have rvm installed and configured.
#####User Setup
To set up your user credentials for github create a .gistUser.yaml file in your home directory that looks like the following: 
```yaml
username: user
password: pass
```
An example credentials file can be found in the setup directory
#####Rvm Setup 
To set up the rvm gemset environment there is a bash script (rvm_setup.sh) in the setup directory you can pass this a version of ruby and this will create the gemset named gistbackup for that version of ruby.
#####Cron Setup 
To configure gist-backup using cron you must call it using the rvm wrappers, that will be a path like; rvm_loc/wrappers/ruby_version@gistbackup/bin/ruby

Usage
--------------
To use gist-backup open your cron file and add a line with the desire time setting, add the location of the rvm gemset ruby and then call gist-backup with the following:
```sh
gistBackup.rb <gist_ID> <gist_file_name> <backup_file_path> <log_level>
```
#### parameters
gist_ID: This is the ID of the gist to back up to
gist_file_name: This is the filename in the gist that you back the file up to 
backup_file_path: This is the fully pathed file that will be the target of the backup 

### optional 
log_level: This is optional and is the level of logging (debug, info, warn, error, fatal), this will default to error

Development
--------------
As with all my projects pull requests are welcome to make this project the best it can be.

Disclaimer
-------------
This is provided without warranty of any kind, the creator(s) and contributors do their best to ensure stablity but can make no warranty about the stability of this module in different environments. The creator(s) and contributors reccomend that you test this module and all future releases of this module in your environment before use.

Contributors
-------------
* [Diego Gutierrez](https://github.com/dgutierrez1287) ([@diego_g](https://twitter.com/diego_g))