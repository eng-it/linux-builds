#!/usr/bin/env qsub
#$ -cwd
#$ -N build-scuff-em
#$ -l s_vmem=8G
#$ -q budge.q
#$ -j y

# Built for use on the LDN compute nodes as documented in INC12055919.
#
# http://homerreid.dyndns.org/scuff-EM/reference/scuffEMInstallation.shtml
#
# Has no official releases so it's all bleeding-edge.

# Don't let common.sh use script path, since for batch job the script is
# copied to another location.  We want paths relative to this directory.
WD="$PWD"
source "$PWD/../common.sh"

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
	# HDF5 versions are different between our CentOS 6 and CentOS 7 nodes,
	# so for now we will just leave it turned off.  Later on we could build
	# a separate hdf5 module at a fixed version to support it if needed.
	export BUILDOPTS="--without-hdf5"
	git_configure_make_install "https://github.com/HomerReid/scuff-em.git"
fi
