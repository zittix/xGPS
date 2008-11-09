#!/bin/bash

set -e

# Pull in config scripts
PATH=$AUTOBUILD_INSTALL_ROOT/bin:$PATH
export PATH
export target=arm-apple-darwin9
export prefix=/iphone/pre
export sysroot=/iphone/sys
export PATH="${prefix}/bin":"${PATH}"
export cctools=/iphone/src/cctools
export gcc=/iphone/src/gcc
export csu=/iphone/src/csu
export CODESIGN_ALLOCATE=/iphone/pre/bin/arm-apple-darwin9-codesign_allocate

# Clean up build area
[ -f Makefile ] && make -k clean ||:

# Make & install 
make
#make install

# Create source code dist
#make dist

