#!/usr/bin/env ruby

# gistBackup #
# A script to backup a file to a gist 

require 'net/http'
require 'json'
require 'net/ping'
require 'logger'
require 'fileutils'
require 'yaml'

## global vars 
$gist_username = nil
$gist_password = nil
$github_api_address = "https://api.github.com"

####################
# get_user_creds()
##
# this will get the user name and password
# from ~/.gistUser and will pull them into 
# global vars for later use
####################
def get_user_creds ()
	
	user_home = ENV["HOME"]
	user_file = IO.read("#{user_home}/.gistUser.yaml")

	user_file_yaml = YAML.parse(user_file)

	$gist_username = user_file_yaml.to_ruby['username'].to_s
	$gist_password = user_file_yaml.to_ruby['password'].to_s
end

###################
# get_current_content(gist_id, gist_file_name)
##
# this will get the current content 
# for the gist to compare to test if 
# the content has changed
##################
def get_current_content (gist_id, gist_file_name)

	uri = URI.parse($github_api_address)
	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	gist_request = Net::HTTP::Get.new("/gists/#{gist_id}")
	gist_request.basic_auth $gist_username, $gist_password

	gist_response = http.request(gist_request)
	$logger.debug "response code for getting the gist is #{gist_response.code}"

	if gist_response.code == "200"

		$logger.debug "github response code 200 ... continuing"

		parsed_response = JSON.parse(gist_response.body)
		gist_file_list = parsed_response["files"]

		if gist_file_list.has_key?(gist_file_name)

			$logger.debug "file found ... getting current content"

			gist_file_hash = gist_file_list[gist_file_name]
			gist_file_content = gist_file_hash["content"]

			$logger.debug "returning content of the file in the gist"
			return gist_file_content
		else 
			$logger.debug "can't file a file with that name in the gist returning file not found"
			return "FOF"
		end
	else 
		$logger.error "ERROR: github is not returning a 200, exiting now..."
		exit 
	end 
end

##################
# update_content(gist_id, gist_file_name, updated_content)
##
# this will update the content for the file 
# in the gist
##################
def update_content(gist_id, gist_file_name, updated_content)

	payload = {
		"files" => {
			"#{gist_file_name}" => {
				"content" => "#{updated_content}"
			}
		}
	}.to_json

	uri = URI.parse($github_api_address)
	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	gist_patch = Net::HTTP::Patch.new("/gists/#{gist_id}")
	gist_patch.basic_auth $gist_username, $gist_password
	gist_patch.body = payload

	patch_response = http.request(gist_patch)
	$logger.debug "response code for the update is #{patch_response.code}"

	if patch_response.code == "200"
		$logger.debug "github patch request successful, response was 200"
	else 
		$logger.error "ERROR: github is not returning a 200, exiting now..."
		exit
	end
end

##################
# print_help()
##
# this will print the help menu for the script
##################
def print_help ()
	puts "gistBackup.rb help: "
	puts " "
  puts "usage: gistBackup.rb <gist_id> <gist_file_name> <backup_file> <log_level>"
  puts " "
  puts "Arguments: "
  puts "gist_id: the ID of the gist that file belongs too"
  puts "gist_file_name: the file name that the is in the gist"
  puts "backup_file: the file to be backedup with fully qualified path"
  puts "log_level: (optional) this must be one of the following;"
  puts "<debug, info, warn, error, fatal> this will default to error"
end

##################
# set_log_level(log_level)
##
# set the level of the logger to a user supplied
# setting 
##################
def set_log_level(log_level)
	case log_level.downcase
	when "debug"
		$logger.level = Logger::DEBUG
	when "info"
		$logger.level = Logger::INFO
	when "warn"
		$logger.level = Logger::WARN
	when "error"
		$logger.level = Logger::ERROR
	when "fatal"
		$logger.level = Logger::FATAL
	else
		$logger.level = Logger::ERROR
	end
end

## MAIN ## 
$script_dir = File.expand_path(File.dirname(__FILE__))
$log_dir = File.expand_path("../log", $script_dir)

# make the log directory
unless File.directory?($log_dir)
	Dir.mkdir($log_dir)
end

$logger = Logger.new File.open("#$log_dir/gistbackup.log", 'a')
$logger.progname = 'general'
$logger.formatter = proc do | severity, datetime, progname, msg |
	"#{severity} #{progname} [#{datetime.strftime('%Y-%m-%d %H:%M:%S.%6N')} ##{Process.pid}]: #{msg}\n"
end

if ARGV[0] == "help"
	print_help
elsif ARGV.empty?
	puts "ERRROR: you must supply some args"
	puts " "
	print_help
elsif ARGV.length < 3
	puts "ERRROR: wrong number of args"
	puts " "
	print_help
else

	if ARGV.length == 4 
		log_level = ARGV[3]
		set_log_level(log_level)
	else 
		$logger.level = Logger::ERROR
	end

	get_user_creds

	$logger.debug "username is #$gist_username"

	gist_id = ARGV[0]
	gist_file_name = ARGV[1]
	backup_file_path = ARGV[2]

	$logger.progname = gist_file_name

	$logger.debug "the gist id is #{gist_id}"
	$logger.debug "the gist file name is #{gist_file_name}"
	$logger.debug "the gist backup_file is #{backup_file_path}"

	# check for internet connection
	if Net::Ping::External.new('www.github.com').ping
		$logger.debug "internet connection found"

		current_content = get_current_content(gist_id, gist_file_name)

		if current_content == "FOF"
			new_file = File.open(backup_file_path, "r")
			new_content = new_file.read
			new_file.close

			update_content(gist_id, gist_file_name, new_content)
		else
			$logger.debug "getting the contents of the file on your computer"
			new_file = File.open(backup_file_path, "r")
			new_content = new_file.read
			new_file.close

			if !current_content.eql?(new_content) 
				$logger.debug "content is different updating gist"
				update_content(gist_id, gist_file_name, new_content)
			else 
				$logger.debug "content is the same, exiting..."
				exit 
			end
		end
	# if there is no internet connection ... exit
	else 
		$logger.debug "no internet connection found"
		exit
	end
end













