#!/bin/bash -e

# Script to install pymol
#
# You will need to have the following packages installed
# through yum
#
#     gcc-c++
#     gcc-gfortran
#     subversion 
#     kernel-devel 
#     python-devel
#     python-pmw 
#     tkinter  
#     glew-devel 
#     freeglut-devel 
#     freetype-devel 
#     libxml2-devel
#     libpng-devel 
#
# This script was tested on CentOS 7 with pymol-1.8.4.0

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
	echo "Build script for pymol"
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

# Pymol source archive directory
src_archive=${arg_src_archive}

# Version
pym_version=${arg_version} 

# Installation directory
prefix=${HOME}/Applications/pymol 

# Create a temporary build directory
mkdir ${working_dir}/temp_pymol
temp_dir=${working_dir}/temp_pymol
cd ${temp_dir}

# Extract the source archive
tar -xvjf ${src_archive}
cd pymol

# Pymol modules location
modules=$prefix/modules

# If you want to install as root, then split this line up in "build"
# and "install" and run the "install" with "sudo"
python2.7 setup.py build install \
    --home=${prefix} \
    --install-lib=${modules} \
    --install-scripts=${prefix}

# Create links
if [ ! -L ${HOME}/bin/pymol ] 
then
    ln -s ${prefix}/pymol ${HOME}/bin/pymol
elif [ -e ${HOME}/bin/pymol ] 
then
    rm -rf ${HOME}/bin/pymol
    ln -s ${prefix}/pymol ${HOME}/bin/pymol
fi

# Cleanup
cd ${working_dir}
rm -rf ${temp_dir}
