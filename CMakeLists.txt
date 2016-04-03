cmake_minimum_required (VERSION 2.8)
project(spectrum C CXX Fortran)

find_package(LAPACK REQUIRED)
link_libraries(lapack)

set(FSRC_REAL comm.f90 covariance_realsp.f90 subspace_realsp.f90 signals_realsp.f90)
set(FMAIN_REAL perf.f90  RunSubspace_realsp.f90)

set(FSRC_CMPL comm.f90 covariance.f90 subspace.f90 signals.f90)
set(FMAIN_CMPL perf.f90  RunSubspace.f90)

set(CSRC cSubspace.c)
set(CPPSRC cppSubspace.cpp)


add_executable(fespritcmpl.out ${FSRC_CMPL} ${FMAIN_CMPL})
add_executable(fespritreal.out ${FSRC_REAL} ${FMAIN_REAL})
add_executable(cesprit.out ${FSRC_REAL} ${CSRC})
add_executable(cppesprit.out ${FSRC_REAL} ${CPPSRC})

# https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html#Option-Summary
# gcc flags also apply to gfortran
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -mtune=native -O3 -ffast-math -Wall -Wextra -Wpedantic -Warray-bounds=2 -fexceptions") 

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c11 -mtune=native -O3 -ffast-math -Wall -Wextra -Wpedantic -Warray-bounds=2 -fexceptions")

# Intel MKL is 2-3 times faster than Lapack and 2016 (v11.3) now no cost:
# https://software.intel.com/en-us/articles/free_mkl
# source /opt/intel/mkl/bin/mklvars.sh intel64
# gfortran  comm.f90 covariance_realsp.f90 subspace_realsp.f90 perf.f90 signals_realsp.f90 RunSubspace_realsp.f90 -std=f2008 -mtune=native -O3 -ffast-math -Wall -Wextra -Wpedantic -Warray-bounds=2 -fcheck=all -fexceptions  -Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_gf_lp64.a ${MKLROOT}/lib/intel64/libmkl_core.a ${MKLROOT}/lib/intel64/libmkl_sequential.a -Wl,--end-group -I${MKLROOT}/include/intel64/lp64 -m64 -I${MKLROOT}/include -L${MKLROOT}/lib/intel64 -lmkl_gf_ilp64 -lmkl_gf_lp64 -lmkl_intel_ilp64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential -lpthread -lmkl_rt -lm -ldl 

SET(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -std=f2008 -mtune=native -O3 -ffast-math -Wall -Wextra -Wpedantic -Warray-bounds=2 -fcheck=all -fexceptions") 
#-Warray-temporaries -Winteger-division -funroll-loops
