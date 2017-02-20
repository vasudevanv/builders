#!/bin/bash

# Script to install vmd on CentOS 7
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
#     tcl-devel
#     tk-devel
#     fltk-devel 
#     netcdf-devel
#
# This script was tested on CentOS 7 with -1.8.4.0

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
ROOT=$(cd $(dirname $0); pwd)

# VMD version
VERSION=${arg_version} 

# System architecture
ARCH="LINUXAMD64"

# Installation paths and names
VMDINSTALLNAME="vmd-$VERSION"
VMDINSTALLBINDIR="${HOME}/Applications/$VMDINSTALLNAME/bin"
VMDINSTALLLIBRARYDIR="${HOME}/Applications/$VMDINSTALLNAME/lib"
TCL_INCLUDE_DIR="/usr/include"
PYTHON_INCLUDE_DIR="/usr/include/python2.7"

# Untar
src_archive=${arg_src_archive}
tar xvzf ${src_archive} 

# Compile the plugins
cd plugins
make clean
make $ARCH TCLINC=-I$TCL_INCLUDE_DIR TCLLIB=-F/usr/lib
make distrib PLUGINDIR=${ROOT}/vmd-${VERSION}/plugins

# Setup environment variabled for compiling VMD
export VMDINSTALLNAME
export VMDINSTALLBINDIR
export VMDINSTALLLIBRARYDIR
export TCL_INCLUDE_DIR
export PYTHON_INCLUDE_DIR
cd ${ROOT}/vmd-$VERSION
ln -sf ${ROOT}/plugins plugins

# Create modified configure file
cp ./configure ./configure.mod
sed -i -e 's/-lpython2\.5/-lpython2.7/g' ./configure.mod
# sed -i -e 's/-ltk8.5/-ltk8.6/g' ./configure.mod
# sed -i -e 's/-ltcl8.5/-ltcl8.6/g' ./configure.mod
chmod +x ./configure.mod

# Configure
./configure.mod LINUXAMD64 \
    OPENGL \
    FLTK \
    TK \
    IMD \
    SILENT \
    TCL \
    PTHREADS \
    NETCDF \
    PYTHON \
    NUMPY

# Compile
cd src
make veryclean
make

# Creating links
make install
if [ -f $HOME/bin/vmd ]
then
    rm -rf $HOME/bin/vmd
fi
ln -s $VMDINSTALLBINDIR/$VMDINSTALLNAME $HOME/bin/vmd

# Cleanup
cd ${ROOT}
rm -rf ${ROOT}/vmd-$VERSION
rm -rf ${ROOT}/plugins
