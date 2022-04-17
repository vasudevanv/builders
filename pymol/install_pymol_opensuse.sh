#!/bin/bash -e

# Script to install pymol
#
# You will need to have the following packages installed
#
#     gcc-c++
#     gcc-gfortran
#     subversion 
#     kernel-devel 
#     python-devel
#     numpy-devel
#     python-pmw 
#     tkinter  
#     glew-devel 
#     freeglut-devel 
#     freetype-devel 
#     libxml2-devel
#     libpng-devel 
#
# This script was tested on OpenSUSE Tumbleweed with a clone of pymol-open-source from April 2022
# The script will need python3 installed.

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
	printf 'Usage: %s [-h|--help] \n' "$0"
	printf "\t%s\n" "-h,--help: Prints help"
}

# Set working directory
working_dir=`pwd`

# Installation directory
prefix=${HOME}/Applications/pymol 

# Create a temporary build directory
mkdir ${working_dir}/temp_pymol
temp_dir=${working_dir}/temp_pymol
cd ${temp_dir}

# Extract the source archive
git clone https://github.com/schrodinger/pymol-open-source.git
git clone https://github.com/rcsb/mmtf-cpp.git
mv mmtf-cpp/include/mmtf* pymol-open-source/include/
cd pymol-open-source

# Pymol modules location
modules=${prefix}/modules

# If you want to install as root, then split this line up in "build"
# and "install" and run the "install" with "sudo"
python3 setup.py install --prefix=${prefix} \
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
