#!/usr/bin/env bash

source $(dirname $0)/../common.sh

# Newer versions of various GNU numerical packages are required
module load mpfr
module load gmp
module load mpc

VER="5.3-2016.05"
PREFIX="$ENGOPT/64/gcc-linaro-$VER"

if [[ ! $0 == "-bash" ]]
then	
	configure_make_install linaro "https://releases.linaro.org/components/toolchain/gcc-linaro/latest-5/gcc-linaro-$VER.tar.xz"
fi
