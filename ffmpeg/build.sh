#!/usr/bin/env bash

# Adapted from this guide:
# https://trac.ffmpeg.org/wiki/CompilationGuide/Centos

FFMPEG_DIR="/ad/eng/support/software/linux/opt/64/ffmpeg"

function yasm()
{
	git clone --depth 1 https://github.com/yasm/yasm.git
	cd yasm
	autoreconf -fiv
	./configure --prefix="$FFMPEG_DIR"
	make
	make install
	make distclean
}

# https://wiki.videolan.org/git
function libx264
{
	#git clone --depth 1 https://git.videolan.org/x264
	git clone http://git.videolan.org/git/x264.git
	cd x264
	PKG_CONFIG_PATH="$FFMPEG_DIR/lib/pkgconfig" ./configure --prefix="$FFMPEG_DIR" --enable-static
	make
	make install
	make distclean
}

function libx265
{
	hg clone https://bitbucket.org/multicoreware/x265
	cd x265/build/linux
	cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$FFMPEG_DIR" -DENABLE_SHARED:bool=off ../../source
	make
	make install
}

function libfdk_aac()
{
	#git clone --depth 1 https://git.code.sf.net/p/opencore-amr/fdk-aac
	git clone --depth 1 http://git.code.sf.net/p/opencore-amr/fdk-aac
	cd fdk-aac
	autoreconf -fiv
	./configure --prefix="$FFMPEG_DIR" --disable-shared
	make
	make install
	make distclean
}

# About the added "-ltinfo":
# https://sourceforge.net/p/lame/mailman/message/32754132/
function libmp3lame()
{
	curl -L -O http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
	tar xzvf lame-3.99.5.tar.gz
	cd lame-3.99.5
	LIBS="-ltinfo" ./configure --prefix="$FFMPEG_DIR" --disable-shared --enable-nasm
	make
	make install
	#make distclean
}

function libopus()
{
	git clone http://git.opus-codec.org/opus.git
	cd opus
	autoreconf -fiv
	./configure --prefix="$FFMPEG_DIR" --disable-shared
	make
	make install
	make distclean
}

function libogg()
{
	curl -O http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz
	tar xzvf libogg-1.3.2.tar.gz
	cd libogg-1.3.2
	./configure --prefix="$FFMPEG_DIR" --disable-shared
	make
	make install
	make distclean
}

function libvorbis()
{
	cd ~/ffmpeg_sources
	curl -O http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz
	tar xzvf libvorbis-1.3.4.tar.gz
	cd libvorbis-1.3.4
	LDFLAGS="-L$FFMPEG_DIR/lib" CPPFLAGS="-I$FFMPEG_DIR/include" ./configure --prefix="$FFMPEG_DIR" --with-ogg="$FFMPEG_DIR" --disable-shared
	make
	make install
	make distclean
}

function libvpx()
{
	git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
	cd libvpx
	./configure --prefix="$FFMPEG_DIR" --disable-examples
	make
	make install
	make clean
}

function ffmpeg()
{
	git clone http://source.ffmpeg.org/git/ffmpeg.git
	cd ffmpeg
	./configure --prefix="$FFMPEG_DIR" --pkg-config-flags="--static" --enable-gpl --enable-nonfree --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265
	make
	make install
	make distclean
	hash -r
}

function ffmpeg_all()
{
	yasm
	libx264
	libx265
	libfdk_aac
	libmp3lame
	libopus
	libogg
	libvorbis
	libvpx
	ffmpeg
}

function main()
{
	# Set up environment
	module load bu-webproxy
	module load gnu-build-system
	module load ffmpeg

	[ -e /tmp/build-ffmpeg ] || mkdir /tmp/build-ffmpeg
	(cd /tmp/build-ffmpeg && ffmpeg_all)
}

if [[ ! $0 == "-bash" ]]
then	
	main
fi
