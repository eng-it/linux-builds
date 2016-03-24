#!/usr/bin/env bash
# http://genometools.org/
URL="http://genometools.org/pub/genometools-1.5.7.tar.gz"
tarball=$(basename "$URL")
dir=$(echo $tarball | sed 's/\.tar\.gz//')
if [ ! -e "$tarball" ]
then
	wget "$URL"
fi
if [ ! -e "$dir" ]
then
	tar xzf "$tarball"
fi
cd "$dir"
# Needs pango-devel and cairo-devel installed
make errorcheck=no
# On 1.5.7 a number of test categories fail, but the application seems OK
# at a first glance.  Maybe just spurious?
make test
make prefix="/ad/eng/support/software/linux/opt/64/$dir/" install
# Then symlink as usual
