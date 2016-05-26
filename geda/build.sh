#!/usr/bin/env bash

# gEDA: GPL-licensed Electronic Design Automation
# http://wiki.geda-project.org/geda:gaf_building_git_version

source $(dirname $0)/../common.sh

# The configure script generated with our newer automake throws errors, but the
# older one seems OK.
module unload automake

# This allows later steps in the install to correctly find dependencies from
# the earlier steps
module load geda

VER="1.8"
PREFIX="$ENGOPT/64/geda-$VER"

function geda()
{
	if [ -d geda-gaf ]
	then
		cd geda-gaf
	else
		git clone http://git.geda-project.org/geda-gaf
	fi
	git checkout stable-$VER
	git pull
	./autogen.sh |& tee $WD/autogen_geda.log
	./configure --prefix=$PREFIX |& tee $WD/configure_geda.log
	make |& tee $WD/make_geda.log
	make install |& tee $WD/make_geda_install.log
}

function main()
{
	# Install dependencies with the usual workflow
	configure_make_install libunistring http://ftp.gnu.org/gnu/libunistring/libunistring-0.9.5.tar.xz
	configure_make_install libffi ftp://sourceware.org/pub/libffi/libffi-3.2.1.tar.gz
	configure_make_install bdw-gc http://www.hboehm.info/gc/gc_source/gc-7.2f.tar.gz
	configure_make_install guile ftp://ftp.gnu.org/gnu/guile/guile-2.0.11.tar.gz
	# Install gEDA with a (slightly) custom procedure
	geda
}

if [[ ! $0 == "-bash" ]]
then	
	main
fi
