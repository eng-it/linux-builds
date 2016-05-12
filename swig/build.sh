#!/usr/bin/env bash

# Note that the compiled swig binary will have a hardcoded reference to the
# SWIG files.  In this case I've left that as-is but included an overriding
# SWIG_LIB variable in the module file, using the non-kerberized path.

source $(dirname $0)/../common.sh

# For python support
module load anaconda/2.7

VER="3.0.8"
PREFIX="$ENGOPT/64/swig-$VER"

function pcre()
{
	VER_PCRE="8.38"
	URL_PCRE="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${VER_PCRE}.tar.bz2"

	get "$URL_PCRE"
	expand $(basename "$URL_PCRE")
	DIR=$(tbz2_maindir $(basename "$URL_PCRE"))

	mkdir -p "/tmp/$USER-build-$DIR"
	cd "/tmp/$USER-build-$DIR"

	$WD/$DIR/configure --prefix=$PREFIX 2>&1 | tee $WD/configure_pcre.log
	make 2>&1 | tee $WD/make_pcre.log
	make install 2>&1 | tee $WD/make_pcre_install.log
}

function swig()
{
	URL="http://prdownloads.sourceforge.net/swig/swig-$VER.tar.gz"

	get "$URL"
	expand $(basename "$URL")
	DIR=$(tgz_maindir $(basename "$URL"))

	mkdir -p "/tmp/$USER-build-$DIR"
	cd "/tmp/$USER-build-$DIR"

	$WD/$DIR/configure --prefix=$PREFIX 2>&1 | tee $WD/configure.log
	make 2>&1 | tee $WD/make.log
	make install 2>&1 | tee $WD/make_install.log
}

function main()
{
	pcre
	swig
}

if [[ ! $0 == "-bash" ]]
then	
	main
fi
