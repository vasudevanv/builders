# builders

Compendia of bash scripts for compiling popular simulation/analysis
codes (gromacs, lammps, ambertools, etc.). Scripts are provided for
the following platforms:

## OpenSUSE (_opensuse)
A ``Tumbleweed`` flavor of OpenSUSE with the following packages installed via
zypper / yast

* gcc-c++
* gcc-gfortran
* cmake
* fftw-devel
* boost-devel
* libbz2-devel
* libXt-devel
* python

If you are on a system with MPI capabilities, you will also need
* openmpi-devel

These scripts can easily be adapted to work with RHEL/Fedora/Rocky linux
systems.

## Mac OS X el Capitan (_mac_elcapitan)
Xcode with commandline tools and Homebrew are installed along with the
following packages (installed through homebrew).
* gcc, gcc5, gcc48
* boost
* fftw
* cmake
* openmpi
* libjpeg
* voro++



