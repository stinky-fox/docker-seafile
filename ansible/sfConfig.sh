#!/bin/bash

#####################################################
# This script is a part of GitHub repository:       #
# https://github.com/stinky-fox/docker-seafile      #
# Purpose of this script is to automatically create #
# "upload" folder, generate upload link and passwd  #
# Requires:				                            #
#		- jq 				                        #
#		- curl				                        #
#####################################################

##################################################
# 		Define variables 	                     #
##################################################

sfNODENAME=$1
sfUSER=$2
sfPSWD=$3


# generate password by hashsum cuurent date and take first 20 chars
lnkPSWD=$(date +%s | sha256sum | base64 | head -c 20 ; echo)

# get API key
sfAPIKEY=$(curl -s -k -d "username=$sfUSER&password=$sfPSWD" "https://127.0.0.1/api2/auth-token/" | jq -r .token)

# get default repository
sfDEFLIB=$(curl -s -k -H "Authorization: Token $sfAPIKEY" "https://127.0.0.1/api/v2.1/admin/default-library/" -X POST -d "user_email=$sfUSER" | jq -r .repo_id)


# make directory /upload

curl -s -k -H "Authorization: Token $sfAPIKEY" -H 'Accept: application/json; charset=utf-8; indent=4' "https://127.0.0.1/api2/repos/$sfDEFLIB/dir/?p=/upload" -X POST -d "operation=mkdir" >> /tmp/out.log
# /dev/null

# share /upload directory as an upload link

upLNK=$(curl -s -k -H "Authorization: Token $sfAPIKEY" -H 'Accept: application/json; indent=4' "https://127.0.0.1/api/v2.1/upload-links/" -X POST -d "path=/upload/&repo_id=$sfDEFLIB&password=$lnkPSWD" | jq -r .link) 

# return link and password
echo "Node: $sfNODENAME | Upload link: $upLNK | Upload Link Password: $lnkPSWD"