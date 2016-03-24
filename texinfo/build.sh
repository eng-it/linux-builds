#!/usr/bin/env bash

module load bu-webproxy
module load gcc
module load automake
module load autoconf
module load libtool

URL="http://ftp.gnu.org/gnu/texinfo/texinfo-6.1.tar.xz"
TXZ=$(basename "$URL")
DIR="$(echo $TXZ | sed 's/\.tar\.xz$//')"
if [[ ! -e "$TXZ" ]]
then
	wget "$URL"
fi
if [[ ! -e "$DIR" ]]
then
	tar xJvf "$TXZ"
fi

cd "$DIR"
./configure --prefix="/ad/eng/support/software/linux/opt/64/$DIR"
make | tee make.log
make install
