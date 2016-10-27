#!/bin/bash
 
# Script to build gromacs-5.1.x on Mac OS X el capitan
# You will need to have homebrew and the following packages 
# installed:
#
#     gcc6
#     boost
#     fftw
#     cmake

# Set the working directory
working_dir=`pwd`

# Directory for the gromacs source archive
src_dir=`pwd`

# Version
gmx_version="5.1.4"

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
 
# Make
cmake -DCMAKE_INSTALL_PREFIX=${install_dir} \
    -DGMX_DEFAULT_SUFFIX=OFF \
    -DGMX_BINARY_SUFFIX="_s" \
    -DGMX_X11=OFF \
    -DGMX_MPI=OFF \
    -DGMX_THREAD_MPI=ON \
    -DCMAKE_CXX_COMPILER=/usr/local/bin/g++-6 \
    -DCMAKE_C_COMPILER=/usr/local/bin/gcc-6 \
    `pwd`
 
make -j4
make install
 
# Cleanup
cd ${working_dir}
rm -rf ${temp_dir}
