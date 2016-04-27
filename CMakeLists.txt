cmake_minimum_required (VERSION 2.8.12)
project(spectrum C CXX Fortran)

#------------ subspace library ---------------
# we build separate libraries for real and complex to avoid polymorphic performance hits and complexities.
find_package(LAPACK)

add_library(subspace_cmpl comm.f90             covariance.f90 subspace.f90 signals.f90)
target_link_libraries(subspace_cmpl lapack)
set_target_properties(subspace_cmpl PROPERTIES Fortran_MODULE_DIRECTORY mod.cmpl)

add_library(subspace_real comm.f90 filters.f90 covariance_realsp.f90 subspace_realsp.f90 signals_realsp.f90)
target_link_libraries(subspace_real lapack)
set_target_properties(subspace_real PROPERTIES Fortran_MODULE_DIRECTORY mod.real)
#------ test program: Fortran Complex Double Precision ----------
add_executable(fespritcmpl perf.f90  RunSubspace.f90)
target_link_libraries(fespritcmpl subspace_cmpl)
set_target_properties(fespritcmpl PROPERTIES Fortran_MODULE_DIRECTORY mod.cmpl)
#------ test program: Fortran Real Single Precision -------------
add_executable(fespritreal perf.f90 RunSubspace_realsp.f90)
target_link_libraries(fespritreal subspace_real)
set_target_properties(fespritreal PROPERTIES Fortran_MODULE_DIRECTORY mod.real)
#------ test program: C++ Real Single ---------------------------
add_executable(cppesprit cppSubspace.cpp)
target_link_libraries(cppesprit subspace_real)
set_target_properties(cppesprit PROPERTIES CXX_STANDARD 14)
#------ test program: C Real Single -----------------------------
add_executable(cesprit cSubspace.c)
target_link_libraries(cesprit subspace_real)
set_target_properties(cesprit PROPERTIES C_STANDARD 11)

#---------------------
#include(compiler.cmake)
add_compile_options(-mtune=native -ffast-math -Wall -Wextra -Wpedantic -fexceptions -Werror=array-bounds)

