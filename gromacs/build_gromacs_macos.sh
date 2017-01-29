#!/bin/bash
 
# Script to build gromacs on macOS
#
# You will need to have homebrew and the following packages 
# installed:
#
#     gcc6
#     boost
#     fftw
#     cmake
#
# This script was tested on macOS Sierra with gromacs-5.1.4
# and gromacs-4.5.5

build3(){
    # Set environment variables
    export CC=/usr/local/bin/gcc-4.8
    export CXX=/usr/local/bin/gcc-4.8 
    export CPPFLAGS=-I/usr/local/include
    export LDFLAGS=-L/usr/local/lib

    # Configure gromacs
    ./configure --prefix=${install_dir} \
		--disable-mpi \
		--program-suffix=_s \
		--without-x \
		--enable-static \
		--enable-float \
		--disable-ia32-sse \
		--disable-ia32-3dnow
}

build4(){
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
}

build45(){
    # Make
    cmake -DCMAKE_INSTALL_PREFIX=${install_dir} \
	  -DGMX_DEFAULT_SUFFIX=OFF \
	  -DGMX_BINARY_SUFFIX="_s" \
	  -DGMX_X11=OFF \
	  -DGMX_MPI=OFF \
	  -DCMAKE_CXX_COMPILER=/usr/local/bin/g++-4.8 \
	  -DCMAKE_C_COMPILER=/usr/local/bin/gcc-4.8 \
	  `pwd`

}

build5(){
    # Build gromacs version 5
    cmake -DCMAKE_INSTALL_PREFIX=${install_dir} \
	  -DGMX_DEFAULT_SUFFIX=OFF \
	  -DGMX_BINARY_SUFFIX="_s" \
	  -DGMX_X11=OFF \
	  -DGMX_MPI=OFF \
	  -DGMX_THREAD_MPI=ON \
	  -DCMAKE_CXX_COMPILER=/usr/local/bin/g++-6 \
	  -DCMAKE_C_COMPILER=/usr/local/bin/gcc-6 \
	  `pwd`
}


# Set working directory
working_dir=`pwd`
 
# Gromacs source archive directory
src_dir=${working_dir}

# Version
gmx_version="5.1.4"
 
# Installation directory
install_dir=${HOME}/Applications/gromacs-${gmx_version}

# Parse arguments
usage() {
    echo "Usage: $0 [-h] [-v] [-f FILE]"
    echo "  version=  Version of gromacs you want to install"
    echo "  prefix=  Installation directory for gromacs"
    echo "  src=  Location of the gromacs source archive"
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

install_dir=${install_dir}/gromacs-${gmx_version}

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

build_version=`echo ${gmx_version} | sed "s/\./\ /" | awk '{print $1}'`
case ${build_version} in
    3) build3 ;;
    4) build4 ;;
    5) build5 ;;
esac
 
make -j4
make install
 
# Cleanup
cd ${working_dir}
rm -rf ${temp_dir}
