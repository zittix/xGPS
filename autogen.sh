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
AUTOBUILD_COUNTER=15432454534
# Clean up build area
[ -f Makefile ] && make -k clean ||:

# Make 
make

#create version file
rm -f -R debian/
mkdir -p debian/DEBIAN/
cp debian_control debian/DEBIAN/control
echo "Version: 1.1-$AUTOBUILD_COUNTER" >> debian/DEBIAN/control
chmod -R 0755 debian/DEBIAN

make dist

#Copy files
cp xGPSBeta.zip $AUTOBUILD_PACKAGE_ROOT/zips/xGPSBeta-$AUTOBUILD_TIMESTAMP.zip
cp xGPSBeta.deb $AUTOBUILD_PACKAGE_ROOT/debian/xGPSBeta-$AUTOBUILD_TIMESTAMP.deb

