#!/bin/bash -e
# Copyright 2016 C.S.I.R. Meraka Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

. /etc/profile.d/modules.sh
. /etc/profile.d/modules.sh
module avail
module add ci
# Add dependencies
module add bzip2
module add ncurses
module add  readline
module  add  gnuplot
module  add  openssl/1.0.2j
module add openblas/0.2.19-gcc-${GCC_VERSION}
module add hdf5/1.8.16-gcc-${GCC_VERSION}-mpi-1.10.2
module add fftw/3.3.4-gcc-${GCC_VERSION}-mpi-1.10.2
module add jdk/8u66
SOURCE_FILE=${NAME}-${VERSION}.tar.gz
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
make check

echo $?

make install
mkdir -p ${REPO_DIR}
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       OCTAVE_VERSION       $VERSION
setenv       OCTAVE_DIR           /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-${GCC_VERSION}
prepend-path LD_LIBRARY_PATH   $::env(OCTAVE_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(OCTAVE_DIR)/include
prepend-path CFLAGS            "-I$::env(OCTAVE_DIR)/include"
prepend-path LDFLAGS           "-L$::env(OCTAVE_DIR)/lib"
MODULE_FILE
) > modules/$VERSION-gcc-${GCC_VERSION}

mkdir -vp ${LIBRARIES}/${NAME}
cp -v modules/$VERSION-gcc-${GCC_VERSION} ${LIBRARIES}/${NAME}


module avail ${NAME}
