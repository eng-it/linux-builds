#!/usr/bin/env bash

# http://www.boost.org/doc/libs/1_60_0/more/getting_started/unix-variants.html

source $(dirname $0)/../common.sh

module load anaconda

VER="1.60.0"
PREFIX="$ENGOPT/64/boost-$VER"

function boost()
{
	name="boost"
	URL="$1"

	filename=$(basename $(get "$URL"))
	expand "$filename"
	DIR=$(maindir "$filename")

	cd $DIR
	./bootstrap.sh --prefix="$PREFIX" 2>&1 | tee $WD/bootstrap.log
	# --layout=system should leave out all the extra suffix bits that get
	# added on for a custom install by default.  Doing this so that builds
	# can just use '-l boost_regex' instead of '-l boost_regex-vc71-mt-...'
	./b2 --layout=system -d+2 install 2>&1 | tee $WD/b2_install.log
}

function main()
{
	
	boost "http://downloads.sourceforge.net/project/boost/boost/1.60.0/boost_1_60_0.tar.bz2"
}

if [[ ! $0 == "-bash" ]]
then	
	main
fi
