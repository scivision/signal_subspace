cmake_minimum_required (VERSION 3.19)

project(spectrum
LANGUAGES C CXX Fortran
VERSION 1.1.1
)

enable_testing()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules/)

include(cmake/compilers.cmake)

find_package(LAPACK REQUIRED)

add_subdirectory(src)

add_subdirectory(test)
