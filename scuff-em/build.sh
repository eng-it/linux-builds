#!/usr/bin/env bash

# Built for use on the LDN compute nodes as documented in INC12055919.
#
# http://homerreid.dyndns.org/scuff-EM/reference/scuffEMInstallation.shtml
#
# Has no official releases so it's all bleeding-edge.

source $(dirname $0)/../common.sh

module load anaconda/2.7
module load gmsh

TODAY="$(date +%Y%m%d)"
PREFIX="$ENGOPT/64/scuff-em-$TODAY"

if [[ ! $0 == "-bash" ]]
then
	# We need to explicitly set the fortran compilers or we'll get
	# GCC-related errors when trying to link against some libstdc++ stuff
	# from GCC.
	export FC=gfortran
	export F77=gfortran
	git_configure_make_install "https://github.com/HomerReid/scuff-em.git"
fi
