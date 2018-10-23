#!/bin/bash
 
# Script to build gromacs-5.1.x
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
# This script was last tested on Centos 7 with gromacs-5.1.4 and 
# gromacs 4.0.7

build34(){
    if [ $# -ne 0 ]
    then
	if [ $1 == "MPI" ]
	then
	./configure --prefix=${install_dir} \
	    --enable-float \
	    --enable-mpi \
	    --program-suffix="_sm" \
	    --without-x
	else
	    echo 'Error: Unknown Argument'
	    exit
	fi
    else
	# Make
	./configure --prefix=${install_dir} \
	    --disable-mpi \
	    --program-suffix=_s \
	    --without-x \
	    --enable-static \
	    --enable-float 
    fi
}


build5(){
    if [ $# -ne 0 ]
    then
	if [ $1 == "MPI" ]
	then
	    cmake -DCMAKE_INSTALL_PREFIX=${install_dir} \
		-DGMX_DEFAULT_SUFFIX=OFF \
		-DGMX_BINARY_SUFFIX="_sm" \
		-DGMX_X11=OFF \
		-DGMX_MPI=ON \
		-DGMX_BUILD_MDRUN_ONLY=ON \
		-DCMAKE_CXX_COMPILER=mpicxx \
		-DCMAKE_C_COMPILER=mpicc \
		`pwd`
	else
	    echo 'Error: Unknown Argument'
	    exit
	fi
    else
	# Build gromacs version 5
	cmake -DCMAKE_INSTALL_PREFIX=${install_dir} \
	    -DGMX_DEFAULT_SUFFIX=OFF \
	    -DGMX_BINARY_SUFFIX="_s" \
	    -DGMX_X11=OFF \
	    -DGMX_MPI=OFF \
	    -DGMX_GPU=OFF \
	    `pwd`
    fi
}


# Set working directory
working_dir=`pwd`
 
# Gromacs source archive directory
src_dir=`pwd`

# Version
gmx_version="5.1.4"
 

# Parse arguments
usage() {
    echo "Usage: $0 [-h] [-v] [-f FILE]"
    echo "  version=  Version of gromacs you want to install"
    echo "  prefix=  Installation directory for gromacs"
    echo "  src=  Location of the gromacs source archive"
    echo "  module=  Location of the gromacs modulefile"
    echo "Gromacs will be installed in gromacs-(version)"
    echo "within the installation directory. The default"
    echo "installation directory is ${HOME}/Applications"
    exit
}

# Parse arguments
has_version=0

for i in "$@" 
do
    case $i in
	version=*)
	    has_version=1
	    gmx_version="${i#*=}"
	    shift # past argument
	    ;;
	prefix=*)
	    install_dir="${i#*=}"
	    shift # past argument
	    ;;
	src=*)
	    src_dir="${i#*=}"
	    shift # past argument
	    ;;
	module=*)
	    module_dir="${i#*=}"
	    shift # past argument
	    ;;
	*)
	    echo "Unknown option" # usage
	    ;;
    esac
    shift # past argument or value
done

if [ ${has_version} -eq 0 ]; then
    echo "Missing gromacs version number"
    usage
fi

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
build_version=`echo ${gmx_version} | sed "s/\./\ /" | awk '{print $1}'`
case ${build_version} in
    3) build34 ;;
    4) build34 ;;
    5|2016) build5 ;;
esac

make -j4
make install
 
# Build the MPI version of mdrun
module load mpi/openmpi-x86_64
cd ${temp_dir}
rm -rf gromacs-${gmx_version}
tar -xzf ${src_dir}/gromacs-${gmx_version}.tar.gz
cd gromacs-${gmx_version}
 
case ${build_version} in
    3) 
	build34 MPI 
	make -j4
	make install-mdrun
	;;
    4) 
	build34 MPI 
	make -j4
	make install-mdrun
	;;
    5|2016) 
	build5 MPI 
	make -j4
	make install
	;;
esac

# Cleanup
cd ${working_dir}
rm -rf ${temp_dir}

if [ ! -z ${module_dir} ]
then
    echo "Creating module file"
    # Write module file
    cat <<EOF > ${module_dir}/gromacs-${gmx_version}
#%Module
## Module to load gromacs into user PATH
proc ModulesHelp { } {

        puts stderr "Loads the Gromacs MD package v ${gmx_version}"
}

module-whatis	 Name: Gromacs
module-whatis	 Version: ${gmx_version}
module-whatis	 Category: physics, molecular dynamics 
module-whatis	 Description: Gromacs molecular dynamics simulation package 
module-whatis	 URL: http://www.gromacs.org
prepend-path	 PATH ${install_dir}/bin
prepend-path	 MANPATH ${install_dir}/share/man 
prepend-path	 LD_LIBRARY_PATH ${install_dir}/lib  
EOF
fi
