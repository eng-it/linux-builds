#!/usr/bin/env bash

# Note that the compiled swig binary will have a hardcoded reference to the
# SWIG files.  In this case I've left that as-is but included an overriding
# SWIG_LIB variable in the module file, using the non-kerberized path.

source $(dirname $0)/../common.sh

VER="3.0.8"
URL="http://prdownloads.sourceforge.net/swig/swig-$VER.tar.gz"
SWIG="/ad/eng/support/software/linux/opt/64/swig-$VER"

# For python support
module load anaconda/2.7

function main()
{
	get "$URL"
	expand $(basename "$URL")
	DIR=$(tgz_maindir $(basename "$URL"))
	WD="$(readlink -f $(dirname $0))"

	mkdir -p "/tmp/$USER-build-$DIR"
	cd "/tmp/$USER-build-$DIR"

	$WD/$DIR/configure --prefix=$SWIG 2>&1 | tee $WD/configure.log
	make 2>&1 | tee $WD/make.log
	make install 2>&1 | tee $WD/make_install.log
}

if [[ ! $0 == "-bash" ]]
then	
	main
fi
