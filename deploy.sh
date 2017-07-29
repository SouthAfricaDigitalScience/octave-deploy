#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
whoami
echo ${SOFT_DIR}
module add deploy
echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
../configure --prefix=${SOFT_DIR} \
--with-blas=${OPENBLAS_DIR}/lib/libopenblas.so \
--with-hdf5-includedir=${HDF5_DIR}/include --with-hdf5-libdir=${HDF5_DIR}/lib \
--with-fftw3-includedir=${FFTW_DIR}/include --with-fftw3-libdir=${FFTW_DIR}/lib \
--with-fftw3f-includedir=${FFTW_DIR}/include --with-fftw3f-libdir=${FFTW_DIR}/lib \
--with-bz2-includedir=${BZLIB_DIR}/include --with-bz2-libdir=${BZLIB_DIR}/lib \
--with-openssl=optional
make

echo "Creating the modules file directory ${LIBRARIES}"
mkdir -p ${LIBRARIES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/gmp-deploy"
setenv OCTAVEV_VERSION       $VERSION
setenv OCTAVE_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(OCTAVE_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(OCTAVE_DIR)/include
prepend-path CFLAGS            "-I$::env(OCTAVE_DIR)/include"
prepend-path LDFLAGS           "-L$::env(OCTAVE_DIR)/lib"
MODULE_FILE
) > ${LIBRARIES}/${NAME}/${VERSION}

module avail $NAME
module add
