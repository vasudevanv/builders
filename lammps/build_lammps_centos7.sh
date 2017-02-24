#!/bin/bash

# Script to build LAMMPS
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
# This script was last tested on Centos 7 with lammps-6Jan17

VERSION=6Jan17

# Location of final install
installdir=${HOME}/Applications/lammps-${VERSION}

# Current working directory
dir=`pwd`

if [ -f ${dir}/lammps-${VERSION}.tar.gz ]
then

    if [ -d ${dir}/lammps-${VERSION} ]
    then
	rm -rf ${dir}/lammps-${VERSION}
    fi
    tar -xzf lammps-${VERSION}.tar.gz
    cd lammps-${VERSION}
    lbase=`pwd`
    lsrc=${lbase}/src
    llib=${lbase}/lib

    # Standard packages: 
    # asphere body class2 colloid compress coreshell dipole fld gpu granular 
    # kim kokkos kspace manybody mc meam misc molecule mpiio opt peri poems 
    # python qeq reax replica rigid shock snap srd voronoi xtc

    # User-contributed packages: 
    # user-atc user-awpmd user-cg-cmm user-colvars user-cuda user-diffraction 
    # user-drude user-eff user-fep user-h5md user-intel user-lb user-misc 
    # user-molfile user-omp user-phonon user-qmmm user-qtb user-quip user-reaxc 
    # user-smd user-sph user-tally

    # Load mpi
    module load mpi/openmpi-x86_64

    # Clean
    make clean-all

    # Build the packages
    echo "Making the colvars package"
    cd ${llib}/colvars
    make -f Makefile.g++
    echo "Finished building the colvars package"
    cd ${lbase}

    echo "Making the meam package"
    cd ${llib}/meam
    make -f Makefile.gfortran
    echo "Finished building the meam package"
    cd ${lbase}

    echo "Making the reax package"
    cd ${llib}/reax
    make -f Makefile.gfortran
    echo "Finished building the reax package"
    cd ${lbase}
    
    echo "Making the poems package"
    cd ${llib}/poems
    make -f Makefile.g++
    echo "Finished building the poems package"
    cd ${lbase}
    
    # exclude all packages
    cd ${lsrc}
    make no-all

    # include standard packages
    make yes-standard
    make no-kim
    make no-gpu

    # include user packages
    make yes-user-colvars
    make yes-user-dpd
    make yes-user-fep
    make yes-user-lb

    # Compile the parallel version of lammps
    make mpi

    # Cleanup
    mv $lbase $installdir
fi
