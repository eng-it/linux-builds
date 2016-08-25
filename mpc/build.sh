#!/usr/bin/env bash

source $(dirname $0)/../common.sh

VER="1.0.3"
PREFIX="$ENGOPT/64/mpc-$VER"

if [[ ! $0 == "-bash" ]]
then	
	configure_make_install mpc "ftp://ftp.gnu.org/gnu/mpc/mpc-$VER.tar.gz"
fi
