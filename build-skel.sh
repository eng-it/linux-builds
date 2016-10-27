#!/usr/bin/env qsub
#$ -cwd
#$ -N APP_NAME
#$ -l s_vmem=4G
#$ -q budge.q
#$ -j y

# Don't let common.sh use script path, since for batch job the script is
# copied to another location.  We want paths relative to this directory.
WD="$PWD"
source "$PWD/../common.sh"

VER=0 # TODO set program version
PREFIX="$ENGOPT/64/app_name-${VER}" # TODO set install prefix

if [[ ! $0 == "-bash" ]]
then
	# TODO use an install command
fi
