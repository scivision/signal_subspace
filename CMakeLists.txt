cmake_minimum_required (VERSION 3.20...3.29)

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
option(CMAKE_TLS_VERIFY "Verify TLS certificates when downloading external projects" ON)
option(python "build python interface")

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
set_property(DIRECTORY PROPERTY EP_UPDATE_DISCONNECTED ON)

if(PROJECT_IS_TOP_LEVEL AND CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/local" CACHE PATH "install prefix" FORCE)
endif()

message(STATUS "${PROJECT_NAME} install prefix: ${CMAKE_INSTALL_PREFIX}")

include(cmake/compilers.cmake)

include(cmake/lapack.cmake)

add_library(subspace OBJECT)
target_compile_options(subspace PRIVATE ${fopts})
target_link_libraries(subspace PRIVATE LAPACK::LAPACK)
set_property(TARGET subspace PROPERTY Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include)
target_include_directories(subspace INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/include)

add_subdirectory(src)

if(python)
include(cmake/f2py.cmake)
endif()

if(BUILD_TESTING)
add_subdirectory(test)
endif()

file(GENERATE OUTPUT .gitignore CONTENT "*")
