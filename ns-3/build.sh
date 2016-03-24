#!/usr/bin/env bash

# https://www.nsnam.org/wiki/Installation

module load anaconda

export CXXFLAGS="-I/ad/eng/opt/64/anaconda-2.0.1-py27/include"
export LDFLAGS="-L/ad/eng/opt/64/anaconda-2.0.1-py27/lib"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/ad/eng/opt/64/anaconda-2.0.1-py27/lib/"

url="https://www.nsnam.org/release/ns-allinone-3.24.1.tar.bz2"
tarball=$(basename "$url")
dirname=$(echo "$tarball" | sed 's/\.tar\.bz2$//')
if [ ! -f "$tarball" ]
then
	wget "$url"
fi
if [ ! -d "$dirname" ]
then
	tar xjvf "$tarball"
fi

cd "$dirname"
# --build-options="--enable-mpi" 
./build.py --enable-examples --enable-tests | tee build.log
