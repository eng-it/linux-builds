#!/usr/bin/env bash

module load bu-webproxy
module load gcc
module load autoconf
module load automake

URL="http://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.xz"
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
