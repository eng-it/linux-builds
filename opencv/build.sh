#!/usr/bin/env bash

# Primarily following the 2.4 install docs, as it doesn't look like there are
# any for 3.X yet:
# http://docs.opencv.org/2.4/doc/tutorials/introduction/linux_install/linux_install.html#linux-installation
# These pages helped with making it work with custom Python:
# http://www.megalinux.net/compiling-opencv-2-4-on-rhelcentos-5
# http://stackoverflow.com/questions/24174394/cmake-is-not-able-to-find-python-libraries
# 
# NOTE: Before rebuilding, rmeove the release directory if anything was changed.

source $(dirname $0)/../common.sh

# CUDA can't handle newer GCC versions
module unload gcc
module load anaconda/2.7
module load ffmpeg
source /ad/eng/opt/64/cuda/cuda-6.0/add_cuda-6.0.sh

VER="3.1.0"
URL="https://codeload.github.com/Itseez/opencv/zip/$VER"
OPENCV="/ad/eng/support/software/linux/opt/64/opencv/$VER"
MATLAB="/ad/eng/opt/matlab-8.5/"
ANACONDA="/ad/eng/opt/64/anaconda/"

function main()
{
	get "$URL"
	expand $(basename "$URL")
	DIR=$(zip_maindir $(basename "$URL"))
	WD="$(readlink -f $(dirname $0))"

	mkdir -p "/tmp/$USER-build-$DIR"
	cd "/tmp/$USER-build-$DIR"

	# It looks like possibly we need the extra "matlab" module to get full Matlab
	# support for OpenCV:
	# https://github.com/Itseez/opencv_contrib/tree/master/modules/matlab
	# Leaving MATLAB_ROOT_DIR included just the same.

	cmake -D BUILD_EXAMPLES=ON \
	      -D PYTHON_EXECUTABLE=$ANACONDA/bin/python \
	      -D PYTHON_INCLUDE_DIR=$ANACONDA/include/python2.7 \
	      -D PYTHON_LIBRARY=$ANACONDA/lib/libpython2.7.so \
	      -D PYTHON_PACKAGES_PATH=$ANACONDA/lib/python2.7/site-packages/ \
	      -D INSTALL_PYTHON_EXAMPLES=ON \
	      -D MATLAB_ROOT_DIR="$MATLAB" \
	      -D CMAKE_BUILD_TYPE=RELEASE \
	      -D CMAKE_INSTALL_PREFIX="$OPENCV" \
	      "$WD/$DIR" 2>&1 | tee "$WD/cmake.log"
	make 2>&1 | tee "$WD/make.log"
	make install 2>&1 | tee "$WD/make_install.log"
}

if [[ ! $0 == "-bash" ]]
then	
	main
fi
