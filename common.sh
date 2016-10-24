#!/usr/bin/env bash

# Load proxy settings if the internet is not reachable
ping -W 1 -c 1 google.com &>/dev/null || module load bu-webproxy

module load gnu-build-system

export ENGOPT="/ad/eng/support/software/linux/opt"
[ $WD  ] || WD="$(readlink -f $(dirname $0 2> /dev/null))" || WD="$PWD"

function get()
{
	URL="$1"
	PKG=$(basename "$URL")
	newurl=$(wget -c -S -q "$URL" 2>&1 | grep '^  Location: ' | tail -n 1 | sed 's/^  Location: //')
	if [[ $newurl == "" ]]
	then
		echo "$URL"
	else
		printf '%b' "${newurl//%/\\x}"
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
			unzip -qfo "$filename" ;;
		*"gzip compressed data"*)
			tar --skip-old-files -xzf "$filename" ;;
		*"bzip2 compressed data"*)
			tar --skip-old-files -xjf "$filename" ;;
		*"xz compressed data"*)
			tar --skip-old-files -xJf "$filename" ;;
		*)
			echo "Can't extract $filename"
			exit 1
			;;
	esac
}

function maindir()
{
	filename="$1"
	filetype=$(file "$filename")
	case $filetype in
		*"Zip archive data"*)
			unzip -qql "$1" | head -n 1 | cut -c 31- ;;
		*"gzip compressed data"*)
			tar -tzf "$1" | head -n 1 ;;
		*"bzip2 compressed data"*)
			tar -tjf "$1" | head -n 1 ;;
		*"xz compressed data"*)
			tar -tJf "$1" | head -n 1 ;;
		*)
			echo "Can't detect maindir for $filename" > /dev/stderr
			exit 1
			;;
	esac
}

function configure_make_install()
{
	name="$1"
	URL="$2"

	filename=$(basename "$(get "$URL")")
	expand "$filename"
	DIR=$(maindir "$filename")

	mkdir -p "/tmp/$USER-build-$DIR"
	pushd "/tmp/$USER-build-$DIR"

	if [ -e $WD/$DIR/configure ]
	then
		$WD/$DIR/configure --prefix=$PREFIX 2>&1 | tee $WD/configure_${name}.log
	fi
	make 2>&1 | tee $WD/make_${name}.log
	make install 2>&1 | tee $WD/make_${name}_install.log
	popd
}

function cmake_make_install()
{
	name="$1"
	URL="$2"

	filename=$(basename "$(get "$URL")")
	expand "$filename"
	DIR=$(maindir "$filename")

	mkdir -p "/tmp/$USER-build-$DIR"
	cd "/tmp/$USER-build-$DIR"

	cmake -D BUILD_SHARED_LIBS=ON \
	      -D CMAKE_INSTALL_PREFIX:PATH="$PREFIX" "$WD/$DIR"
	make 2>&1 | tee $WD/make_${name}.log
	make install 2>&1 | tee $WD/make_${name}_install.log
}

function git_configure_make_install()
{
	URL="$1"
	name="$(echo $URL | sed 's/^.*\///;s/\.git$//')"
	if [ -d "$name" ]
	then
		( cd "$name" && git pull )
	else
		git clone --depth 1 "$URL"
	fi
	pushd "$name"
	if [ -f autogen.sh ]
	then
		cmd="autogen.sh"
	else
		cmd="configure"
	fi
	"./$cmd" --prefix="$PREFIX" $BUILDOPTS 2>&1 | tee "$WD/${cmd}_${name}.log"
	make install 2>&1 | tee "$WD/make_${name}_install.log"
	popd
}

#
# Below functions obsoleted by the single maindir() above
#

function zip_maindir()
{
	unzip -qql $1 | head -n 1 | cut -c 31-
}

function tgz_maindir()
{
	tar -tzf $1  | head -n 1
}

function tbz2_maindir()
{
	tar -tjf $1  | head -n 1
}
