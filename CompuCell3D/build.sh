#!/usr/bin/env bash

# Steps:
# Install python 2.7
# Compile Qt 4.8.xxx
# Compile sip from PyQt4 package
# Compile PyQt4 4.xxx
# Compile QScintilla with Python bindings
#
# Then, for CompuCell3D:
# Generally follow http://www.compucell3d.org/SrcBin/LinuxCompileFedora
# But, within cmake-gui:
#   * set the installation prefix to a NetApp location: /ad/eng/support/software/linux/opt/64/CompuCell3D/
#   * Check NO_OPENCL to disable compiling an optional feature (which fails for some reason)
#   * Set python paths to use miniconda
#   * set VTK_DIR to miniconda/lib/vtk-5.10

D="$(pwd)"
if [[ $0 != '-bash' ]]; then
	D="$(dirname $(readlink -e $0))"
fi
CC3D_DIR="/ad/eng/support/software/linux/opt/64/CompuCell3D"
CC3D_DIR_CONDA="$CC3D_DIR/miniconda"
CC3D_DIR_QT4="$CC3D_DIR/opt/Qt4"
###CC3D_DIR_PYQT4="$CC3D_DIR/opt/PyQt4"
TGZ='s/\.tar\.gz//'

# 1) Python
# Putting ananconda's miniconda distrubtion inside CC3D dir
function install_python()
{
	miniconda="http://repo.continuum.io/miniconda/Miniconda-3.7.0-Linux-x86_64.sh"
	wget -cnv "$miniconda"
	ex="$(basename $miniconda)"
	chmod +x "$ex"
	./"$ex" -b -f -p "$CC3D_DIR_CONDA"
	# Then, conda install scipy numpy
}

# 1) Qt4
# If it complains about gstreamer-app-0.10 do this:
#     yum install 'pkgconfig(gstreamer-app-0.10)
# http://comments.gmane.org/gmane.comp.lib.qt.user/1314
function qt4()
{
	qt="http://download.qt-project.org/official_releases/qt/4.8/4.8.6/qt-everywhere-opensource-src-4.8.6.tar.gz"
	wget -cnv "$qt"
	tar xzf "$(basename $qt)"
	qt_dir=$(echo $(basename "$qt") | sed "$TGZ")
	# webkit is giving us trouble; trying without it.
	yes | "$qt_dir/configure" -opensource -prefix "$CC3D_DIR_QT4" -no-webkit
	(cd "$qt_dir" && gmake)
	gmake install
}

# 2) sip and PyQt4
function pyqt()
{
	# http://www.riverbankcomputing.com/software/sip/download
	# http://www.riverbankcomputing.com/software/pyqt/download
	pyqt="http://sourceforge.net/projects/pyqt/files/PyQt4/PyQt-4.11.2/PyQt-x11-gpl-4.11.2.tar.gz"
	sip="http://sourceforge.net/projects/pyqt/files/sip/sip-4.16.4/sip-4.16.4.tar.gz"

	# Sip
	# http://pyqt.sourceforge.net/Docs/sip4/installation.html
	wget -cnv "$sip"
	tar xzf "$(basename $sip)"
	pyqt_sip_dir=$(echo $(basename $sip) | sed "$TGZ")
	(cd "$pyqt_sip_dir" && yes | python configure.py)
	(cd "$pyqt_sip_dir" && make && make install)

	# PyQt4
	# http://pyqt.sourceforge.net/Docs/PyQt4/installation.html
	wget -cnv "$pyqt"
	tar xzf "$(basename $pyqt)"
	pyqt_dir=$(echo $(basename $pyqt) | sed "$TGZ")
	export CPLUS_INCLUDE_PATH="$CC3D_DIR_CONDA/include:$CC3D_DIR_CONDA/include/python2.7"
	(cd "$pyqt_dir" && python configure-ng.py --confirm-license --qmake "$CC3D_DIR_QT4/bin/qmake" --qsci-api --target-py-version=2.7)
	# This leaves an empty PyQt4 install (?)
	#(cd "$pyqt_dir" && python configure-ng.py --confirm-license --qmake "$CC3D_DIR_QT4/bin/qmake" --sip-incdir="$CC3D_DIR_CONDA/include/python2.7/" --qsci-api --static --target-py-version=2.7 --configuration $D/pyqt.conf)
	# This doesn't work; py_inc_dir is only available in a conf file, apparently
	#(cd "$pyqt_dir" && python configure-ng.py --confirm-license --qmake "$CC3D_DIR_QT4/bin/qmake" --sip-incdir="$CC3D_DIR_CONDA/include/python2.7/" --qsci-api --static --target-py-version=2.7 --py-inc-dir /ad/eng/opt/64/CompuCell3D/miniconda/include/python2.7/)
	(cd "$pyqt_dir" && make && make install)
}

# 3) QScintilla
# First QScintilla itself, then Python bindings
function qsci()
{
	# http://www.riverbankcomputing.com/software/qscintilla/download
	qsci="http://sourceforge.net/projects/pyqt/files/QScintilla2/QScintilla-2.8.4/QScintilla-gpl-2.8.4.tar.gz"
	#wget -c "$qsci"
	#tar xzf "$(basename $qsci)"
	qsci_dir=$(echo $(basename $qsci) | sed "$TGZ")
	# http://pyqt.sourceforge.net/Docs/QScintilla2/
	# "As supplied QScintilla will be built as a shared library/DLL and installed
	# in the same directories as the Qt libraries and include files."
	#(cd "$qsci_dir/Qt4Qt5" && "$CC3D_DIR_QT4/bin/qmake" qscintilla.pro && make && make install)
	# Now for the python bindings
	#export CPLUS_INCLUDE_PATH="$CC3D_DIR_CONDA/include:$CC3D_DIR_CONDA/include/python2.7"
	(cd "$qsci_dir/Python" && python configure.py --qmake "$CC3D_DIR_QT4/bin/qmake")
	(cd "$qsci_dir/Python" && make && make install)
}

function setup_python()
{
	export PYTHONHOME="$CC3D_DIR_CONDA"
	export PYTHONLIB=$PYTHONHOME/lib:$PYTHONHOME/lib/python2.7/site-packages
	#export PYTHONPATH=$PYTHONHOME/bin:$PYTHONHOME/python2.7/site-packages
	export PYTHONPATH=$PYTHONHOME/bin
	pathmunge () {
		if ! echo $PATH | /bin/egrep -q "(^|:)$1($|:)" ; then
		PATH=$1:$PATH
		fi
	}
	pathmunge $PYTHONHOME/bin
}

#function setup_qt()
#{
#	export QTDIR="$CC3D_DIR"
#	export QTLIB="$QTDIR/lib"
#	export QTINC="$QTDIR/include"
#}

function main()
{
	#install_python
	setup_python
	#[ -e qt4  ] || mkdir qt4
	#(cd qt4 && qt4)
	#[ -e pyqt ] || mkdir pyqt
	#(cd pyqt && pyqt)
	[ -e qsci ] || mkdir qsci
	(cd qsci && qsci)
}

if [[ ! $0 == "-bash" ]]
then	
	main
fi
