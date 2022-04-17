#!/bin/bash
 
# Script to build plumed 2
#
# You will need to have the following packages installed
#
#
# This script was tested on Opensuse Tumbleweed with plumed-2.8.0
#
# The installation will be in ${HOME}/Applications/plumed-${VERSION}.
# After installtion, you will need to link plumed to other tools
# using their respective options to this directory


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
	echo "Build script for plumed2"
	printf 'Usage: %s [-h|--help] <src_archive> \n' "$0"
	printf "\t%s\n" "<src_archive>: source tar file"
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
test ${#_positionals[@]} -lt 1 && _PRINT_HELP=yes die "FATAL ERROR: Not enough a
rguments - require 2, but got only ${#_positionals[@]}." 1
test ${#_positionals[@]} -gt 1 && _PRINT_HELP=yes die "FATAL ERROR: Spurious arg
uments - require 2, but got ${#_positionals[@]}." 1
for (( ii = 0; ii < ${#_positionals[@]}; ii++))
do
    eval "${_positional_names[ii]}=\${_positionals[ii]}" || die "Error during ar
gument parsing. Possibly a bug in the script" 1
done

# Set working directory
working_dir=`pwd`
 
# Gromacs source archive directory
src_archive=`readlink -f ${arg_src_archive}`
src_folder=`basename ${arg_src_archive} .tgz`

# Installation directory
install_dir=${HOME}/Applications/${src_folder}

# Create a temporary build directory
# Extract the source archive
temp_dir=${working_dir}/temp

if [ -d ${temp_dir} ]
then
    rm -rf ${temp_dir}
fi
mkdir ${temp_dir}
cd ${temp_dir}
tar -xzf ${src_archive}
cd ${temp_dir}/${src_folder}

# Configure
./configure --prefix=${install_dir}

# Make
make
make install

# Cleanup
cd ${working_dir}
rm -rf ${temp_dir}
