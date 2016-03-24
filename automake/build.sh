#!/usr/bin/env bash

module load bu-webproxy
module load gcc

URL="http://ftp.gnu.org/gnu/automake/automake-1.15.tar.xz"
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
make 2>&1 | tee make.log
make install
