#!/bin/bash
 
# Script to build gromacs-4.0.x
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
# This script was tested on Scientific Linux 7 with gromacs-4.0.7

# Set working directory
working_dir=`pwd`
 
# Gromacs source archive directory
src_dir=`pwd`

# Version
gmx_version="4.0.7"
 
# Installation directory
install_dir=${HOME}/Applications/gromacs-${gmx_version}

# Create a temporary build directory
mkdir ${working_dir}/temp
temp_dir=${working_dir}/temp
cd ${temp_dir}

# Extract the source archive
if [ -d ${temp_dir}/gromacs-${gmx_version} ]
then
    rm -rf ${temp_dir}/gromacs-${gmx_version}
fi
tar -xzf ${src_dir}/gromacs-${gmx_version}.tar.gz
cd ${temp_dir}/gromacs-${gmx_version}
 
# Build gromacs
./configure --prefix=${install_dir} \
    --enable-float \
    --disable-mpi \
    --program-suffix="_s" \
    --without-x
 
make -j4
make install
 
# Build the MPI version of mdrun
module load mpi/openmpi-x86_64
cd ${temp_dir}
rm -rf gromacs-${gmx_version}
tar -xzf ${src_dir}/gromacs-${gmx_version}.tar.gz
cd gromacs-${gmx_version}

./configure --prefix=${install_dir} \
    --enable-float \
    --enable-mpi \
    --program-suffix="_sm" \
    --without-x

make -j4
make install-mdrun
 
# Cleanup
cd ${working_dir}
rm -rf ${temp_dir}
