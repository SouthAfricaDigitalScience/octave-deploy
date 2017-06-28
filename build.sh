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

mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}
mkdir -p ${SOFT_DIR}

#  Download the source file

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's geet the source"
  wget https://ftp.gnu.org/gnu/octave/${SOURCE_FILE} -O ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi
tar xjf  ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
mkdir -p ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
../configure --prefix=${SOFT_DIR} \
--with-blas=${OPENBLAS_DIR}/lib/libopenblas.so \
--with-hdf5-includedir=${HDF5_DIR}/include --with-hdf5-libdir=${HDF5_DIR}/lib \
--with-fftw3-includedir=${FFTW_DIR}/include --with-fftw3-libdir=${FFTW_DIR}/lib \
--with-fftw3f-includedir=${FFTW_DIR}/include --with-fftw3f-libdir=${FFTW_DIR}/lib \
--with-bz2-includedir=${BZLIB_DIR}/include --with-bz2-libdir=${BZLIB_DIR}/lib \
--with-openssl=optional
make
