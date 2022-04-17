#!/bin/bash

# Script to build LAMMPS
#
# You will need to have the following packages installed
#
#     gcc-c++
#     gcc-gfortran
#     fftw-devel
#     openmpi-devel - if installing MPI version
#     plumed - see the plumed install script
#
#
# This script was last tested on Opensuse Tumbleweed with lammps-24Mar2022
# You will need to modigy this script to install the MPI version

VERSION=24Mar2022

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

    # Load mpi
    # module load mpi/openmpi-x86_64

    # Clean
    make clean-all

    # exclude all packages
    cd ${lsrc}
    make no-all

    # include additional packages
    make lib-h5md args="-m h5cc"
    make lib-plumed args="-p ${HOME}/Applications/plumed-2.8.0/"
    #make lib-hdnnp args="-b"
    make lib-voronoi args="-b"
    make lib-colvars args="-m serial"
    make lib-poems args="-m serial"
    
    make yes-most
    make yes-plumed
    make no-kim
    make no-gpu

    # Compile the parallel version of lammps
    make serial

    # Symlink
    cd ${lbase}
    ln -s ${lsrc}/lmp_serial ${lbase}/lmp_serial

    # Cleanup and move to right location
    mv $lbase $installdir
fi

if [ ! -z ${module_dir} ]
then
    echo "Creating module file"

    # Write module file
    if [ ! -d ${module_dir}/lammps ]
    then
	mkdir -p ${module_dir}/lammps
    fi

    cat <<EOF > ${module_dir}/lammps/${VERSION}
#%Module
## Module to load lammps into user PATH
proc ModulesHelp { } {

        puts stderr "Loads the LAMMPS MD package v ${VERSION}"
}

module-whatis	 Name: LAMMPS
module-whatis	 Version: ${VERSION}
module-whatis	 Category: physics, molecular dynamics 
module-whatis	 Description: LAMMPS molecular dynamics simulation package 
module-whatis	 URL: http://www.lammps.org
prepend-path	 PATH ${installdir}/bin
prepend-path	 MANPATH ${installdir}/share/man 
prepend-path	 LD_LIBRARY_PATH ${installdir}/lib  
EOF
fi
