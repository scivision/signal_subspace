cmake_minimum_required (VERSION 3.1)
project(spectrum C CXX Fortran)

# cmake -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DCMAKE_Fortran_COMPILER=/usr/bin/gfortran ..

list(APPEND CMAKE_Fortran_FLAGS "-std=f2008 -fbacktrace -Warray-bounds=2") 
add_compile_options(-mtune=native -ffast-math -Wall -Wextra -Wpedantic -fexceptions)
if (${CMAKE_CXX_COMPILER_ID} STREQUAL Clang)
    list(APPEND CMAKE_CXX_FLAGS "-Weverything -Werror=array-bounds")
    list(APPEND CMAKE_C_FLAGS "-Weverything -Werror=array-bounds")
elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL GNU)
    add_compile_options(-Warray-bounds=2)
endif()

set(CMAKE_VERBOSE_MAKEFILE OFF) # see what the individual compiler commands are

# ------------ Build mode selections ---------------------------------
set(CMAKE_BUILD_TYPE Release) #invokes (some) compiler optimizations
#set(CMAKE_BUILD_TYPE Debug) # no optimizations, (some) debug flags on, injects debugging symbols

find_library(LAPACK_FOUND LAPACK)# HINTS /usr/lib/lapack)
link_libraries(lapack)


add_library(subspace_cmpl comm.f90 filters.f90 covariance.f90 subspace.f90 signals.f90)
add_library(subspace_real comm.f90 filters.f90 covariance_realsp.f90 subspace_realsp.f90 signals_realsp.f90)

add_executable(fespritcmpl perf.f90  RunSubspace.f90)
target_link_libraries(fespritcmpl subspace_cmpl)

add_executable(cppesprit cppSubspace.cpp)
target_link_libraries(cppesprit subspace_real)

add_executable(cesprit cSubspace.c)
target_link_libraries(cesprit subspace_real)

add_executable(fespritreal perf.f90 RunSubspace_realsp.f90)
target_link_libraries(fespritreal subspace_real)

set_property(TARGET cesprit PROPERTY C_STANDARD 11)
set_property(TARGET cppesprit PROPERTY CXX_STANDARD 14)
# https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html#Option-Summary
# gcc flags also apply to gfortran

# Intel MKL is 2-3 times faster than Lapack and 2016 (v11.3) now no cost:
# https://software.intel.com/en-us/articles/free_mkl
# source /opt/intel/mkl/bin/mklvars.sh intel64
# gfortran  comm.f90 covariance_realsp.f90 subspace_realsp.f90 perf.f90 signals_realsp.f90 RunSubspace_realsp.f90 -std=f2008 -mtune=native -O3 -ffast-math -Wall -Wextra -Wpedantic -Warray-bounds=2 -fcheck=all -fexceptions  -Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_gf_lp64.a ${MKLROOT}/lib/intel64/libmkl_core.a ${MKLROOT}/lib/intel64/libmkl_sequential.a -Wl,--end-group -I${MKLROOT}/include/intel64/lp64 -m64 -I${MKLROOT}/include -L${MKLROOT}/lib/intel64 -lmkl_gf_ilp64 -lmkl_gf_lp64 -lmkl_intel_ilp64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential -lpthread -lmkl_rt -lm -ldl 

#-Warray-temporaries -Winteger-division -funroll-loops
