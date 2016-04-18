cmake_minimum_required (VERSION 3.1)
project(spectrum C CXX Fortran)

include(compiler.cmake) # boilerplate compiler flags

set(CMAKE_VERBOSE_MAKEFILE off)
#------------ subspace library ---------------
# we build separate libraries for real and complex to avoid polymorphic performance hits and complexities.
find_package(LAPACK)

add_library(subspace_cmpl comm.f90             covariance.f90 subspace.f90 signals.f90)
target_link_libraries(subspace_cmpl lapack)

add_library(subspace_real comm.f90 filters.f90 covariance_realsp.f90 subspace_realsp.f90 signals_realsp.f90)
target_link_libraries(subspace_real lapack)
#------ test program: Fortran Real Single Precision ------------
#add_executable(fespritcmpl perf.f90  RunSubspace.f90)
#target_link_libraries(fespritcmpl subspace_cmpl)
#------ test program: Fortran Complex Double Precision ----------
add_executable(fespritreal perf.f90 RunSubspace_realsp.f90)
target_link_libraries(fespritreal subspace_real)
#------ test program: C++ Real Single ---------------------------
add_executable(cppesprit cppSubspace.cpp)
target_link_libraries(cppesprit subspace_real)
set_property(TARGET cppesprit PROPERTY CXX_STANDARD 14)
#------ test program: C Real Single -----------------------------
add_executable(cesprit cSubspace.c)
target_link_libraries(cesprit subspace_real)
set_property(TARGET cesprit PROPERTY C_STANDARD 11)


