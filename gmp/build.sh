#!/usr/bin/env bash

# https://gmplib.org/

source $(dirname $0)/../common.sh

VER="4.3.2"
URL="http://gmplib.org/download/gmp/archive/gmp-${VER}.tar.bz2"
PREFIX="$ENGOPT/64/gmp-$VER"

function main()
{
	get "$URL"
	expand $(basename "$URL")
	DIR=$(tbz2_maindir $(basename "$URL"))

	mkdir -p "/tmp/$USER-build-$DIR"
	cd "/tmp/$USER-build-$DIR"

	$WD/$DIR/configure --prefix=$PREFIX 2>&1 | tee $WD/configure.log
	make 2>&1 | tee $WD/make.log
	make check 2>&1 | tee $WD/make_check.log
	make install 2>&1 | tee $WD/make_install.log
}

if [[ ! $0 == "-bash" ]]
then	
	main
fi
