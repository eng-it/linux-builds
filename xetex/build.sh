#!/usr/bin/env bash
module load bu-webproxy
if [[ ! -e xetex-code ]]
then
	git clone http://git.code.sf.net/p/xetex/code xetex-code
fi

module load gcc
module load autoconf
module load automake
module load libtool
module load make
module load texinfo
#export PATH=/ad/eng/opt/64/automake-1.15/share/automake-1.15/:$PATH
#export AC_CONFIG_AUX_DIR=/ad/eng/opt/64/automake-1.15/share/automake-1.15/
#export DATAROOTDIR=/ad/eng/opt/64/automake-1.15/share/automake-1.15/

cd xetex-code && ./build.sh
