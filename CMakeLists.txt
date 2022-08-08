cmake_minimum_required (VERSION 3.19)

project(spectrum
LANGUAGES C CXX Fortran
VERSION 1.1.1
)

enable_testing()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(cmake/compilers.cmake)

find_package(LAPACK REQUIRED)

if(NOT LAPACK_d_FOUND)
  message(FATAL_ERROR "need LAPACK real64 'd' but not found")
endif()

if(NOT LAPACK_s_FOUND)
  message(FATAL_ERROR "need LAPACK real32 's' but not found")
endif()

check_fortran_source_compiles(
"program check
use, intrinsic :: iso_fortran_env, only : real32
implicit none (type, external)
complex(real32), external :: cnrm2
print *, cnrm2(1, [0._real32], 1)
end program"
LAPACK_c_FOUND
SRC_EXT f90
)

if(NOT LAPACK_c_FOUND)
  message(FATAL_ERROR "need LAPACK complex64 'c' but not found")
endif()

check_fortran_source_compiles(
"program check
use, intrinsic :: iso_fortran_env, only : real64
implicit none (type, external)
complex(real64), external :: znrm2
print *, znrm2(1, [0._real64], 1)
end program"
LAPACK_z_FOUND
SRC_EXT f90
)

if(LAPACK_z_FOUND)
  set(HAVE_COMPLEX true)
endif()

add_subdirectory(src)

add_subdirectory(test)
