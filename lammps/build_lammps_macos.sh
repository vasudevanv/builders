#!/bin/bash

#!/bin/bash
 
# Script to build lammps on a MAC OS X machine running Lion.


# Script to compile LAMMPS and some optional libraries
# You will need to have the following packages installed
# through homebrew
#
#    fftw
#    gfortran
#    openmpi
#    voro++
#
# This script was tested on Mac OS X El Capitan with lammps-21Feb17

version=21Feb17

# Directory where LAMMPS will be installed
install_dir=${HOME}/Applications

# Directory where the source zip is located
source_dir=`pwd`

# Set current working directory
working_dir=`pwd`


# Untar the current version
temp_dir=${working_dir}/temp
mkdir ${temp_dir}
cd ${temp_dir}
tar -xzf ${source_archive}

# Switch to lammps directory
cd ${temp_dir}/lammps-${version}
lbase=`pwd`
 
# Patch the lammps packages
cp ${working_dir}/Makefile.mac_mpi ${lbase}/src/MAKE/MACHINES/
    
# Make the lammps-packages
cd ${lbase}/lib/meam
make -f Makefile.gfortran
 
cd ${lbase}/lib/poems
make -f Makefile.g++
 
cd ${lbase}/lib/reax
make -f Makefile.gfortran
 
cd ${lbase}/lib/colvars
make -f Makefile.g++

cd ${lbase}/lib/voronoi
if [ -L includelink ]
then
    rm -rf includelink
    rm -rf liblink
fi
ln -s /usr/local/include/voro++/ includelink
ln -s /usr/local/lib liblink

# Remove MS-CG
rm -rf ${lbase}/lib/mscg
rm -rf ${lbase}/src/MSCG

# Make LAMMPS packages
cd ${lbase}/src
make no-all
make yes-standard
make no-gpu
make no-kim
make no-kokkos
make yes-user-colvars
make yes-user-lb
make yes-user-dpd
    
# Compile lammps
make -j4 mac_mpi

# Place installation in final location and cleanup
cd ${working_dir}
ln -s ${lbase}/src/lmp_mac_mpi ${lbase}/lmp_mac_mpi
mv ${lbase} ${install_dir}/
    
echo 'Finished compiling lammps'
echo 'The lammps executable is located at' ${install_dir}/lammps-${version}/lmp_mpi

cd ${working_dir}
rm -rf ${temp_dir}

    
