#!/usr/bin/env bash

# Steps:
# Compile Qt 4.8.xxx
# Compile Doxygen 1.8.5
#
# Then, for morpheus:
# Generally follow https://gitlab.com/morpheus.lab/morpheus
# But, within cmake:
#   * set the installation prefix to a NetApp location: /ad/eng/support/software/linux/opt/64/morpheus

D="$(pwd)"
if [[ $0 != '-bash' ]]; then
	D="$(dirname $(readlink -e $0))"
fi

MORPH_DIR="/ad/eng/support/software/linux/opt/64/morpheus"
TGZ='s/\.tar\.gz//'

# 1) Qt4
# If it complains about gstreamer-app-0.10 do this:
#     yum install 'pkgconfig(gstreamer-app-0.10)
# http://comments.gmane.org/gmane.comp.lib.qt.user/1314
function qt4()
{
	qt="http://download.qt.io/archive/qt/4.8/4.8.6/qt-everywhere-opensource-src-4.8.6.tar.gz"
	qt_tgz="$(basename $qt)"
	qt_dir=$(echo $(basename "$qt") | sed "$TGZ")
	if [[ ! -e "$qt_tgz" ]]
	then
		wget -cnv "$qt"
	fi
	if [[ ! -e "$qt_dir" ]]
	then
		tar xzf "$(basename $qt)"
	fi
	(yes | "$qt_dir/configure" -webkit -verbose -opensource -prefix "$MORPH_DIR" ) | tee configure.log
	(cd "$qt_dir" && gmake 2>&1) | tee gmake.log
	gmake install 2>&1 | tee gmake_install.log
}

function qt4_rpms()
{
	repo="https://repos.fedorapeople.org/repos/sic/qt48/epel-6/x86_64"
	for rpm in qt48-qt-4.8.4-1.el6.x86_64.rpm \
		qt48-qt-webkit-4.8.4-1.el6.x86_64.rpm \
		qt48-runtime-1-3.el6.noarch.rpm \
		qt48-qt-devel-4.8.4-1.el6.x86_64.rpm \
		qt48-qt-webkit-devel-4.8.4-1.el6.x86_64.rpm \
		qt48-qt-x11-4.8.4-1.el6.x86_64.rpm
	do
		if [ ! -e "$rpm" ]
		then
			wget "$repo/$rpm"
		fi
		rpm2cpio "$rpm" | cpio -idmv
	done
	rsync -rl opt/rh/qt48/root/ /ad/eng/support/software/linux/opt/64/morpheus/
}

#function setup_qt()
#{
#	export QTDIR="$MORPH_DIR"
#	export QTLIB="$QTDIR/lib"
#	export QTINC="$QTDIR/include"
#}

function doxygen()
{
	dg="ftp://ftp.stack.nl/pub/users/dimitri/doxygen-1.8.5.src.tar.gz"
	dg_tgz="$(basename $dg)"
	dg_dir=$(echo "$dg_tgz" | sed "s/\.src\.tar\.gz//")
	if [[ ! -e "$dg_tgz" ]]
	then
		wget -cnv "$dg"
	fi
	if [[ ! -e "$dg_dir" ]]
	then
		tar xzf "$dg_tgz"
	fi
	(cd "$dg_dir" && ./configure --prefix "$MORPH_DIR" 2>&1 ) | tee configure.log
	(cd "$dg_dir" && make 2>&1 ) | tee make.log
	(cd "$dg_dir" && make install 2>&1 ) | tee make_install.log
}

function morpheus()
{
	[ -e .git ] || git clone --depth 1 https://gitlab.com/morpheus.lab/morpheus.git .
	rm -rf build
	mkdir -p build
	cd build
	cmake -DCMAKE_INSTALL_PREFIX="$MORPH_DIR" .. 2>&1 | tee ../cmake.log
	make 2>&1 | tee ../make.log
}

function main()
{
	export PATH=/usr/lib64/qt4/bin:/sbin:/usr/sbin:/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/ad/eng/bin/64:/ad/eng/bin/32:/ad/eng/bin:/usr/local/IT/bin:/ad/eng/sbin/64:/ad/eng/sbin/32:/ad/eng/sbin

	# Set up environment
	module load bu-webproxy
	module load gcc
	module load make
	module load automake
	module load autoconf
	module load morpheus
	 
	which qmake
	which gmake
	which rcc

	# for the other compiled packages in the same directory
	#export PATH="/ad/eng/opt/64/morpheus/bin:$PATH"
	#export PATH="/ad/eng/opt/64/CompuCell3D/opt/Qt4/bin/:$PATH"
	#alias qcollectiongenerator=/ad/eng/opt/64/CompuCell3D/opt/Qt4/bin/qcollectiongenerator
	#export CPATH="/ad/eng/opt/64/CompuCell3D/opt/Qt4/include/"
	#export LD_LIBRARY_PATH="/ad/eng/opt/64/morpheus/lib"
	#export LIBRARY_PATH="/ad/eng/opt/64/morpheus/include"

	#[ -e qt4  ] || mkdir qt4
	#(cd qt4 && qt4)

	#[ -e qt4_rpms  ] || mkdir qt4_rpms
	#(cd qt4_rpms && qt4_rpms)

	#[ -e doxygen ] || mkdir doxygen
	#(cd doxygen && doxygen)

	[ -e /tmp/morpheus ] || mkdir /tmp/morpheus
	(cd /tmp/morpheus && morpheus)
}

if [[ ! $0 == "-bash" ]]
then	
	main
fi
