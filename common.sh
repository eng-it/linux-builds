#!/usr/bin/env bash

module load bu-webproxy
module load gnu-build-system

function get()
{
	URL="$1"
	PKG=$(basename "$URL")
	if [[ ! -e "$PKG" ]]
	then
		wget "$URL"
	fi
}

# Modified from:
# http://stackoverflow.com/questions/17420994/bash-regex-match-string
# TODO other common archive types as we go
function expand()
{
	filename="$1"
	filetype=$(file "$filename")
	case $filetype in
		*"Zip archive data"*)
			unzip -qfo $filename ;;
		*"gzip compressed data, was"*)
			tar --skip-old-files -xzf $filename ;;
		*)
			echo "Can't extract $filename"
			exit 1
			;;
	esac
}

function zip_maindir()
{
	unzip -qql $1 | head -n 1 | cut -c 31-
}

function tgz_maindir()
{
	tar -tzf $1  | head -n 1
}
