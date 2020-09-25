cmake_minimum_required (VERSION 3.14)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "default release type")
endif()

project(spectrum
LANGUAGES C CXX Fortran
VERSION 1.1.1)

include(CTest)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules/)

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/compilers.cmake)

find_package(LAPACK REQUIRED)

add_subdirectory(src)

if(BUILD_TESTING)
  add_subdirectory(src/tests)
endif()

if(PROJECT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
  include(FeatureSummary)
  add_feature_info(LTO lto_supported "Link time optimization")
  feature_summary(WHAT ALL)
endif()
