#!/usr/bin/env qsub
#$ -cwd
#$ -N build-libctl
#$ -l s_vmem=4G
#$ -q budge.q
#$ -j y

# http://ab-initio.mit.edu/wiki/index.php/Libctl

# Don't let common.sh use script path, since for batch job the script is
# copied to another location.  We want paths relative to this directory.
WD="$PWD"
source "$PWD/../common.sh"

VER=3.2.2
PREFIX="$ENGOPT/64/libctl-${VER}"

if [[ ! $0 == "-bash" ]]
then
	# why isn't the math library included by default?
	export LIBS=-lm
	configure_make_install libctl "http://ab-initio.mit.edu/libctl/libctl-${VER}.tar.gz"
fi
