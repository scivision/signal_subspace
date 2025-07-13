cmake_minimum_required (VERSION 3.20...4.0)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR "Please use out-of-source build like
  cmake -B build")
endif()

get_property(is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(NOT is_multi_config AND NOT (CMAKE_BUILD_TYPE OR DEFINED ENV{CMAKE_BUILD_TYPE}))
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Release default")
endif()


project(subspace
LANGUAGES C CXX Fortran
VERSION 1.1.2
)

enable_testing()

option(BUILD_TESTING "Build tests" ON)
option(python "build python interface")

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
set_property(DIRECTORY PROPERTY EP_UPDATE_DISCONNECTED ON)

message(STATUS "${PROJECT_NAME} install prefix: ${CMAKE_INSTALL_PREFIX}")

include(cmake/compilers.cmake)

find_package(LAPACK REQUIRED)

set(CMAKE_REQUIRED_LIBRARIES LAPACK::LAPACK)
check_source_compiles(Fortran
"program check_lapack
use, intrinsic :: iso_fortran_env, only : real64
implicit none
real(real64), external :: dznrm2
complex(real64) :: x = 0.
print *, dznrm2(1, x, 1)
end program"
LAPACK_z_FOUND
)

add_library(subspace OBJECT)
target_compile_options(subspace PRIVATE ${fopts})
target_link_libraries(subspace PRIVATE LAPACK::LAPACK)
set_property(TARGET subspace PROPERTY Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include)
target_include_directories(subspace INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/include)

add_subdirectory(src)

if(python)
set(f2py_src
${CMAKE_CURRENT_SOURCE_DIR}/src/comm.f90
${CMAKE_CURRENT_SOURCE_DIR}/src/covariance.f90
${CMAKE_CURRENT_SOURCE_DIR}/src/subspace.f90
)
include(cmake/f2py.cmake)
endif()

if(BUILD_TESTING)
add_subdirectory(test)
endif()

file(GENERATE OUTPUT .gitignore CONTENT "*")
