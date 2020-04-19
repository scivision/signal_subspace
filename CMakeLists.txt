cmake_minimum_required (VERSION 3.14)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "default release type")
endif()

project(spectrum
LANGUAGES C Fortran
VERSION 1.0.4)

enable_testing()
include(CTest)

# we build separate libraries for real and complex to avoid polymorphic performance hits and complexities.
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules/)

set(CTEST_TEST_TIMEOUT 15)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
# *** DO NOT use -ffast-math *** it screws up the signaling between modules
include(cmake/compilers.cmake)

find_package(LAPACK REQUIRED)

add_subdirectory(src)

if(PROJECT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
  add_subdirectory(src/tests)

  include(FeatureSummary)
  add_feature_info(LTO lto_supported "Link time optimization")
  feature_summary(WHAT ALL)
endif()