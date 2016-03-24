#!/usr/bin/env bash

module load bu-webproxy
module load automake
module load autoconf
module load libtool
module load gcc

URL="http://ftp.gnu.org/gnu/make/make-4.1.tar.gz"
TGZ=$(basename "$URL")
DIR="$(echo $TGZ | sed 's/\.tar\.gz$//')"
if [[ ! -e "$TGZ" ]]
then
	wget "$URL"
fi
if [[ ! -e "$DIR" ]]
then
	tar xzvf "$TGZ"
fi

cd "$DIR"
./configure --prefix="/ad/eng/support/software/linux/opt/64/$DIR"
make | tee make.log
make install
