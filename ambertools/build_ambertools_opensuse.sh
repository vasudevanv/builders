#!/bin/bash

# Script to install Ambertools 21 on OpenSUSE Tumbleweed
# The following packages need to be installed
#
#     tcsh
#     patch
#     gcc-c++
#     gcc-gfortran
#     fftw-devel
#     openmpi-devel
#     python-2.7
#     scipy
#     matplotlib
#     tkinter
#     libXt-devel
#     flex
#     bison
#     libbz2-devel
#
# The script was last tested with Ambertools16 and OpenSUSE Tumbleweed

# Argument parsing
die()
{
	local _ret=$2
	test -n "$_ret" || _ret=1
	test "$_PRINT_HELP" = yes && print_help >&2
	echo "$1" >&2
	exit ${_ret}
}

print_help ()
{
	echo "Build script for ambertools"
	printf 'Usage: %s [-h|--help] <src_archive> <version>\n' "$0"
	printf "\t%s\n" "<src_archive>: source tar file"
	printf "\t%s\n" "<version>: version"
	printf "\t%s\n" "-h,--help: Prints help"
}

while test $# -gt 0
do
    _key="$1"
    case "$_key" in
	-h|--help)
	    print_help
	    exit 0
	    ;;
	*)
	    _positionals+=("$1")
	    ;;
    esac
    shift
done

_positional_names=('arg_src_archive' 'arg_version')
test ${#_positionals[@]} -lt 2 && _PRINT_HELP=yes die "FATAL ERROR: Not enough a
rguments - require 2, but got only ${#_positionals[@]}." 1
test ${#_positionals[@]} -gt 2 && _PRINT_HELP=yes die "FATAL ERROR: Spurious arg
uments - require 2, but got ${#_positionals[@]}." 1
for (( ii = 0; ii < ${#_positionals[@]}; ii++))
do
    eval "${_positional_names[ii]}=\${_positionals[ii]}" || die "Error during ar
gument parsing. Possibly a bug in the script" 1
done

# Set working directory
working_dir=`pwd`

# Pymol source archive directory
src_archive=`readlink -f ${arg_src_archive}`

# Version
amb_version=$(expr ${arg_version} - 1)

# Installation directory
install_dir=${HOME}/Applications/amber

# Extract the source archive
if [ ! -f ${src_archive} ]
then
    echo 'Error: ${src_archive} source archive not found!'
    exit
fi

if [ ! -d ${install_dir} ]
then
    mkdir ${install_dir}
fi
cd ${install_dir}
tar -xjf ${src_archive}

# Set Environment Variables
export AMBERHOME=${install_dir}/amber${amb_version}_src

# Configure amber
cd ${AMBERHOME}/build


# Install amber
./run_cmake
make install

# Cleanup
cd ${working_dir}

