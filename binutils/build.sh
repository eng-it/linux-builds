#!/usr/bin/env bash

dirname="binutils-2.26"
cd "$dirname"
./configure --prefix="/ad/eng/support/software/linux/opt/64/$dirname" | tee configure.log
make
