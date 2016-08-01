#!/usr/bin/env bash
#
# https://github.com/astra-toolbox/astra-toolbox

source $(dirname $0)/../common.sh

module unload gcc # dang matlab can't handle our newfangled GCC 5.2.1
module load boost
module load anaconda
MATLAB="/ad/eng/opt/matlab-8.6/"
CUDA="/ad/eng/opt/64/cuda/cuda-6.0/"

VER="1.7.1"
PREFIX="$ENGOPT/64/astra-toolbox-$VER"

function astra()
{
	URL="$1"

	filename=$(basename $(get "$URL"))
	expand "$filename"
	DIR=$(maindir "$filename")

	pushd "$DIR"
	pushd "build/linux"
	./autogen.sh |& tee $WD/autogen.log
	./configure \
	      --with-matlab="$MATLAB" \
	      --with-cuda="$CUDA" \
	      --with-python \
	      --prefix="$PREFIX" |& tee $WD/configure.log
	make |& make.log
	make install |& make_install.log
	popd
	cp -ur samples "$PREFIX"
	popd
}

function main()
{
	
	astra "https://github.com/astra-toolbox/astra-toolbox/archive/v$VER.tar.gz"
}

if [[ ! $0 == "-bash" ]]
then	
	main
fi
