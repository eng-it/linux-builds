#!/usr/bin/env bash

#URL="http://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.xz"
URL="http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.xz"
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

module load gcc

cd "$DIR"
./configure --prefix="/ad/eng/support/software/linux/opt/64/$DIR"
make | tee make.log
make install
