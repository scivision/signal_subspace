cmake_minimum_required (VERSION 2.8.12)
project(spectrum C CXX Fortran)

# *** DO NOT use -ffast-math *** it screws up the signaling between modules!!
add_compile_options(-mtune=native -Wall -Wextra -pedantic -fexceptions -Werror=array-bounds)

if(${CMAKE_Fortran_COMPILER_ID} STREQUAL "Intel")
    add_compile_options(-L/opt/intel/lib -lifcore -limf -lsvml -lintlc -lmkl)
endif()
#------------ subspace library ---------------
# we build separate libraries for real and complex to avoid polymorphic performance hits and complexities.
find_package(LAPACK) #or other math library providing the linear algebra e.g. MKL

add_library(subspace_cmpl comm.f90             covariance.f90 subspace.f90 signals.f90)
target_link_libraries(subspace_cmpl lapack)
set_target_properties(subspace_cmpl PROPERTIES Fortran_MODULE_DIRECTORY mod.cmpl)
target_compile_options(subspace_cmpl PRIVATE -std=f2008ts)

add_library(subspace_real comm.f90 filters.f90 covariance_realsp.f90 subspace_realsp.f90 signals_realsp.f90)
target_link_libraries(subspace_real lapack)# svml intlc ifcore imf)
set_target_properties(subspace_real PROPERTIES Fortran_MODULE_DIRECTORY mod.real)
target_compile_options(subspace_real PRIVATE -std=f2008ts)
#------ test program: Fortran Complex Double Precision ----------
add_executable(fespritcmpl perf.f90  RunSubspace.f90)
target_link_libraries(fespritcmpl subspace_cmpl)
set_target_properties(fespritcmpl PROPERTIES Fortran_MODULE_DIRECTORY mod.cmpl)
target_compile_options(fespritcmpl PUBLIC -std=f2008ts)
#------ test program: Fortran Real Single Precision -------------
add_executable(fespritreal perf.f90 RunSubspace_realsp.f90)
target_link_libraries(fespritreal subspace_real)
set_target_properties(fespritreal PROPERTIES Fortran_MODULE_DIRECTORY mod.real)
target_compile_options(fespritreal PUBLIC -std=f2008ts)
#------ test program: C++ Real Single ---------------------------
add_executable(cppesprit cppSubspace.cpp)
target_link_libraries(cppesprit subspace_real)
set_target_properties(cppesprit PROPERTIES CXX_STANDARD 14)
#------ test program: C Real Single -----------------------------
add_executable(cesprit cSubspace.c)
target_link_libraries(cesprit subspace_real)
set_target_properties(cesprit PROPERTIES C_STANDARD 11)


#---- intel compiler
# note that you can compile first with GCC then link with ICPC (kind of silly 
# since main computation is done in Fortran, but just to show the concept)
# cmake ..
# make
# icpc ../cppSubspace.cpp libsubspace_real.a -lgfortran -llapack

# using Intel Compiler requires linking:
# svml intlc ifcore imf
# that do not work for GCC
# 
# cd bin
# rm -r *
# FC=ifort CC=icc CXX=icpc cmake ..
# make
# icpc ../cppSubspace.cpp libsubspace_real.a -lifcore -lsvml -lintlc -limf


