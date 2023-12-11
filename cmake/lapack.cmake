include(GNUInstallDirs)
include(ExternalProject)

find_package(LAPACK)

if(LAPACK_d_FOUND AND LAPACK_s_FOUND AND LAPACK_c_FOUND AND LAPACK_z_FOUND)
  return()
endif()

set(BUILD_SINGLE true)
set(BUILD_DOUBLE true)
set(BUILD_COMPLEX true)
set(BUILD_COMPLEX16 true)

set(LAPACK_z_FOUND true)


set(lapack_cmake_args
-DBUILD_SINGLE:BOOL=${BUILD_SINGLE}
-DBUILD_DOUBLE:BOOL=${BUILD_DOUBLE}
-DBUILD_COMPLEX:BOOL=${BUILD_COMPLEX}
-DBUILD_COMPLEX16:BOOL=${BUILD_COMPLEX16}
-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
-DCMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
-DCMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
-DBUILD_TESTING:BOOL=off
-DCMAKE_BUILD_TYPE:STRING=Release
)

set(LAPACK_INCLUDE_DIRS ${CMAKE_INSTALL_FULL_INCLUDEDIR})
file(MAKE_DIRECTORY ${LAPACK_INCLUDE_DIRS})
if(NOT IS_DIRECTORY ${LAPACK_INCLUDE_DIRS})
  message(FATAL_ERROR "Could not create directory: ${LAPACK_INCLUDE_DIRS}")
endif()

# CMake generator expression doesn't work for these
if(BUILD_SHARED_LIBS)
  set(LAPACK_LIBRARIES
  ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}lapack${CMAKE_SHARED_LIBRARY_SUFFIX}
  ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}blas${CMAKE_SHARED_LIBRARY_SUFFIX}
  )
else()
  set(LAPACK_LIBRARIES
  ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}lapack${CMAKE_STATIC_LIBRARY_SUFFIX}
  ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}blas${CMAKE_STATIC_LIBRARY_SUFFIX}
  )
endif()



ExternalProject_Add(lapack
GIT_REPOSITORY https://github.com/Reference-LAPACK/lapack.git
GIT_TAG v3.12.0
GIT_SHALLOW TRUE
GIT_PROGRESS TRUE
CMAKE_ARGS ${lapack_cmake_args}
TEST_COMMAND ""
BUILD_BYPRODUCTS ${LAPACK_LIBRARIES}
CONFIGURE_HANDLED_BY_BUILD true
USES_TERMINAL_DOWNLOAD true
USES_TERMINAL_UPDATE true
USES_TERMINAL_PATCH true
USES_TERMINAL_CONFIGURE true
USES_TERMINAL_BUILD true
USES_TERMINAL_INSTALL true
USES_TERMINAL_TEST true
)

if(NOT TARGET LAPACK::LAPACK)
  add_library(LAPACK::LAPACK INTERFACE IMPORTED GLOBAL)
endif()
set_property(TARGET LAPACK::LAPACK PROPERTY INCLUDE_DIRECTORIES "${LAPACK_INCLUDE_DIRS}")
set_property(TARGET LAPACK::LAPACK PROPERTY IMPORTED_LOCATION "${LAPACK_LIBRARIES}")

add_dependencies(LAPACK::LAPACK lapack)