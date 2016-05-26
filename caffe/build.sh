#!/usr/bin/env bash

# Built for request in INC11959621
#
# https://github.com/BVLC/caffe/releases
# http://caffe.berkeleyvision.org/install_yum.html
# http://caffe.berkeleyvision.org/installation.html#compilation
#
# Building support for:
#   CUDA <- add_cuda-6.0.sh
#   Python <- OpenCV <- caffe module
#   OpenCV <- caffe module
#   BLAS w/ local OS package
# 
# Not including MATLAB as it was having trouble compiling against Anaconda for
# some reason.  If there's demand for it we could try harder on that.
#
# Packages we might need to install on nodes:
#   protobuf
#   hdf5
#   snappy
#   leveldb
#   lmdb

source $(dirname $0)/../common.sh

module load boost
module load ffmpeg
# CUDA can't handle newer GCC versions
module unload gcc
module load caffe
source /ad/eng/opt/64/cuda/cuda-6.0/add_cuda-6.0.sh

VER="rc3"
PREFIX="$ENGOPT/64/caffe-$VER"

GFLAGS_VER="1.7"
GLOG_VER="0.3.3"

#OPENCV="/ad/eng/support/software/linux/opt/64/opencv/$VER"
#MATLAB="/ad/eng/opt/matlab-8.5/"
ANACONDA="/ad/eng/opt/64/anaconda/"

# switched to using the CMAKE method instead.
function caffe()
{
	name="caffe"
	URL="$1"

	filename=$(basename $(get "$URL"))
	expand "$filename"
	DIR=$(maindir "$filename")

	cp -u Makefile.config $DIR
	cd $DIR
	make 2>&1 | tee $WD/make_${name}.log
	make install 2>&1 | tee $WD/make_${name}_install.log
}

function caffe_cmake()
{
	name="caffe"
	URL="$1"

	filename=$(basename $(get "$URL"))
	expand "$filename"
	DIR=$(maindir "$filename")

	cd $DIR
	mkdir -p build
	cd build

	# If we wanted matlab support, turn on these for cmake below:
	#-D BUILD_matlab=ON \
	#-D Matlab_mex=/ad/eng/bin/mex83 \
	#-D Matlab_mexext=/ad/eng/bin/mexext83 \
	cmake -D BLAS=open \
	      -D CMAKE_INSTALL_PREFIX:PATH="$PREFIX" \
	      -D PYTHON_INCLUDE_DIR=$ANACONDA/include/python2.7 \
	      -D PYTHON_LIBRARY=$ANACONDA/lib/libpython2.7.so \
	      .. 2>&1 | tee $WD/cmake_${name}.log
	make 2>&1 | tee $WD/make_${name}.log
	make install 2>&1 | tee $WD/make_${name}_install.log
	make runtest 2>&1 | tee $WD/make_${name}_runtest.log
}

function main()
{
	# Before caffe_cmake I ended up having to remove the local packages for
	# gflags and gflags-devel, so that it would use our compiled version
	# instead.  I'm not sure why that was necessary but re-installing those
	# packages afterward it still seemed OK.
	configure_make_install gflags "https://github.com/gflags/gflags/archive/v${GFLAGS_VER}.tar.gz"
	configure_make_install glog "https://github.com/google/glog/archive/v${GLOG_VER}.tar.gz"
	caffe_cmake "https://github.com/BVLC/caffe/archive/${VER}.tar.gz"
	# Post-install I manually copied these directories into
	# $PREFIX/caffe-files:
	#  - data
	#  - examples
	#  - models
	#  - scripts
	# It looks like they assume you'll work directly from the build
	# directory and have read/write access to everything, but copying
	# example files to a separate directory seems to work OK too.

}

if [[ ! $0 == "-bash" ]]
then	
	main
fi
