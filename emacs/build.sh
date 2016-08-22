#!/usr/bin/env bash

source $(dirname $0)/../common.sh

VER="24.5"
PREFIX="$ENGOPT/64/emacs-$VER"

if [[ ! $0 == "-bash" ]]
then	
	configure_make_install emacs "http://ftpmirror.gnu.org/emacs/emacs-$VER.tar.xz"
fi
