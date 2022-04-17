#!/bin/bash
 
# Script to build xdrfile-1.1.x
#
# You will need to have the following packages installed
#
#     gcc-c++
#     gcc-gfortran
#     fftw-devel
#     openmpi-devel (if installing MPI version)
#
#
# This script was tested on OpenSUSE Tumbleweed March 2022 
# with xdrfile-1.1.4

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
	echo "Build script for gromacs xdrfile"
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
test ${#_positionals[@]} -lt 2 && _PRINT_HELP=yes die "FATAL ERROR: Not enough arguments - require 2, but got only ${#_positionals[@]}." 1
test ${#_positionals[@]} -gt 2 && _PRINT_HELP=yes die "FATAL ERROR: Spurious arguments - require 2, but got ${#_positionals[@]}." 1
for (( ii = 0; ii < ${#_positionals[@]}; ii++))
do
    eval "${_positional_names[ii]}=\${_positionals[ii]}" || die "Error during argument parsing. Possibly a bug in the script" 1
done

# Set working directory
working_dir=`pwd`
 
# Gromacs source archive directory
src_archive=`readlink -f ${arg_src_archive}`

# Version
xdr_version=${arg_version} 
 
# Installation directory
install_dir=${HOME}/Applications/xdrfile-${xdr_version}

# Create a temporary build directory
mkdir ${working_dir}/temp
temp_dir=${working_dir}/temp
cd ${temp_dir}

# Extract the source archive
if [ -d ${temp_dir}/xdrfile-${xdr_version} ]
then
    rm -rf ${temp_dir}/xdrfile-${xdr_version}
fi
tar -xzf ${src_archive}
cd ${temp_dir}/xdrfile-${xdr_version}
 
# Build xdrfile
make clean
./configure --prefix=${install_dir} 
 
make -j4
make install
 
# Cleanup
cd ${working_dir}
rm -rf ${temp_dir}
