cmake_minimum_required (VERSION 3.12)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Debug or Release")
endif()
project(spectrum C Fortran)
enable_testing()

# we build separate libraries for real and complex to avoid polymorphic performance hits and complexities.
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/Modules/)

# *** DO NOT use -ffast-math *** it screws up the signaling between modules!!
include(cmake/compilers.cmake)

find_package(LAPACK REQUIRED)

add_library(subspace filters.f90 covariance.f90 subspace.f90 signals.f90 perf.f90)
if(f2018)
  target_sources(subspace PRIVATE comm.f90)
else()
  target_sources(subspace PRIVATE comm_legacy.f90)
endif()
target_link_libraries(subspace PRIVATE ${LAPACK_LIBRARIES})

#------ test program: Fortran Complex Double Precision ----------
add_executable(fespritcmpl RunSubspace.f90)
target_link_libraries(fespritcmpl subspace)
add_test(NAME FortranComplexEsprit COMMAND fespritcmpl)
set_tests_properties(FortranComplexEsprit PROPERTIES TIMEOUT 15)
#------ test program: Fortran Real Single Precision -------------
add_executable(fespritreal RunSubspace_realsp.f90)
target_link_libraries(fespritreal subspace)
add_test(NAME FortranRealEsprit COMMAND fespritreal)
set_tests_properties(FortranRealEsprit PROPERTIES TIMEOUT 15)
#------ test program: C++ Real Single ---------------------------
include(CheckLanguage)
check_language(CXX)
if(CMAKE_CXX_COMPILER)
  enable_language(CXX)

  add_executable(cppesprit cppSubspace.cpp)
  target_link_libraries(cppesprit subspace)
  set_target_properties(cppesprit PROPERTIES CXX_STANDARD 11)
  add_test(NAME C++Esprit COMMAND cppesprit)
  set_tests_properties(C++Esprit PROPERTIES TIMEOUT 15)
endif()
#------ test program: C Real Single -----------------------------
add_executable(cesprit cSubspace.c)
target_link_libraries(cesprit subspace)
set_target_properties(cesprit PROPERTIES C_STANDARD 11)
add_test(NAME C-Esprit COMMAND cesprit)
set_tests_properties(C-Esprit PROPERTIES TIMEOUT 15)
