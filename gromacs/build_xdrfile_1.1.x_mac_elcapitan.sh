#!/bin/bash
 
# Script to build xdrfile-1.1.x
#
# You will need to have the following packages installed
# through yum
#
#     gcc-c++
#     gcc-gfortran
#     fftw-devel
#     openmpi-devel
#
# The script assumes that mpi is available as a module
# which can be loaded using module load mpi/openmpi-x86_64
#
# This script was tested on Scientific Linux 7 with xdrfile-1.1.4

# Set working directory
working_dir=`pwd`
 
# Gromacs source archive directory
src_dir=`pwd`

# Version
xdr_version="1.1.4"
 
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
tar -xzf ${src_dir}/xdrfile-${xdr_version}.tar.gz
cd ${temp_dir}/xdrfile-${xdr_version}
 
# Build xdrfile
make clean
./configure --prefix=${install_dir} 
 
make -j4
make install
 
# Cleanup
cd ${working_dir}
rm -rf ${temp_dir}
