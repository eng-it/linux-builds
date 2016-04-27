#!/usr/bin/env bash

# http://www.mpfr.org/

source $(dirname $0)/../common.sh

VER="2.4.2"
URL="http://www.mpfr.org/mpfr-${VER}/mpfr-${VER}.tar.bz2"
PREFIX="$ENGOPT/64/mpfr-$VER"

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
