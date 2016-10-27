#!/bin/bash
 
# Script to build gromacs-4.5.x on Mac OS X el capitan
# You will need to have homebrew and the following packages
# installed
#
#     gcc48
#     boost
#     fftw
#     cmake

# Set the working directory 
working_dir=`pwd`
 
# Directory for the gromacs source archive
src_dir=`pwd`

# Version
gmx_version="4.0.7"

# Installation directory
install_dir=${working_dir}/gromacs-${gmx_version}

# Create a temporary build directory
mkdir ${working_dir}/temp
temp_dir=${working_dir}/temp
cd ${temp_dir}

# Extract the source
if [ -d ${temp_dir}/gromacs-${gmx_version} ]
then
    rm -rf ${temp_dir}/gromacs-${gmx_version}
fi
tar -xzf ${src_dir}/gromacs-${gmx_version}.tar.gz
cd ${temp_dir}/gromacs-${gmx_version}

# Set environment variables
export CC=/usr/local/bin/gcc-4.8
export CXX=/usr/local/bin/gcc-4.8 
export CPPFLAGS=-I/usr/local/include
export LDFLAGS=-L/usr/local/lib

# Make
./configure --prefix=${install_dir} \
	    --disable-mpi \
	    --program-suffix=_s \
	    --without-x \
	    --enable-static \
	    --enable-float \
	    --disable-ia32-sse \
	    --disable-ia32-3dnow

make -j4
make install
 
# Cleanup
cd ${working_dir}
rm -rf ${temp_dir}
