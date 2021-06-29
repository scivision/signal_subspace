cmake_minimum_required (VERSION 3.19...3.21)

project(spectrum
LANGUAGES C CXX Fortran
VERSION 1.1.1)

include(CTest)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules/)

include(cmake/compilers.cmake)

find_package(LAPACK REQUIRED)

add_subdirectory(src)

if(BUILD_TESTING)
  add_subdirectory(src/tests)
endif()
