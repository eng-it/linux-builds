#!/usr/bin/env bash

# (Confusing) Elsevier isntructions for LaTeX use:
# https://www.elsevier.com/authors/author-schemas/latex-instructions

module load bu-webproxy

function get_ctan()
{
	package="$1"
	fmt="http://mirrors.ctan.org/macros/latex/contrib/%s.zip"
	URL=$(printf $fmt $package)
	if [ ! -e $package.zip ]
	then
		wget "$URL"
	fi
	unzip -u $package.zip
}

function get_archive()
{
	URL="$1"
	archive="$(basename "$URL")"
	name="$(echo "$archive" | sed 's/\..*$//')"
	if [ ! -e "$archive" ]
	then
		wget --no-check-certificate "$URL"
	fi
	unzip -u -d "$name" "$archive"
}

function make_latex()
{
	dirname="$1"
	cd "$dirname" && pdflatex *.ins
}

# Get the base Elsevier package and build the elsarticle.cls file with pdflatex
get_ctan "elsarticle"
make_latex "elsarticle"
# Get their elsarticle template and bibtex files (NOT elsarticle-ecrc like the
# page says).  Not sure this is needed, though; there's also the elsarticle
# class from CTAN and the separate elsarticle-ecrc.zip below.
get_archive "https://www.elsevier.com/__data/assets/file/0007/56842/elsarticle-template.zip"

# So what about the files for "Camera-Ready Copy" journals?
# Maybe these instructions instead:
# https://www.elsevier.com/authors/author-schemas/preparing-crc-journal-articles-with-latex
get_archive "https://www.elsevier.com/__data/assets/file/0004/56938/elsarticle-ecrc.zip"
make_latex "elsarticle-ecrc"
