#!/usr/bin/env bash
# Adapted from custom script originally used to install CGAL for RT Ticket
# 146184 (whatever that was).

# http://doc.cgal.org/latest/Manual/installation.html

source $(dirname $0)/../common.sh

VER="4.6"
PREFIX="$ENGOPT/64/cgal-$VER"
URL="https://gforge.inria.fr/frs/download.php/latestfile/2743/CGAL-$VER.tar.bz2"

if [[ ! $0 == "-bash" ]]
then	
	cmake_make_install cgal "$URL"
fi
