if(CMAKE_BUILD_TYPE STREQUAL Debug)
  add_compile_options(-g -O0)
else()
  add_compile_options(-O3)
endif()


if(${CMAKE_Fortran_COMPILER_ID} STREQUAL Intel)
    list(APPEND CLIBS ifcoremt imf svml intlc)
   # list(APPEND FFLAGS -check all -fpe0 -warn -traceback -debug extended)
    if (MKL_FOUND)
        list(APPEND FFLAGS8 -i8)
    endif()
elseif(${CMAKE_Fortran_COMPILER_ID} STREQUAL GNU)
  if(${CMAKE_Fortran_COMPILER_VERSION} VERSION_GREATER_EQUAL 8)
    list(APPEND FFLAGS -std=f2018)
  endif()
# NOTE: -fdefault-integer-8 -m64  are crucial for MKL using gfortran to avoid SIGSEGV at runtime!
    list(APPEND FLAGS -mtune=native -Wall -Werror=array-bounds -Wextra -Wpedantic -fexceptions)
    list(APPEND FFLAGS -fall-intrinsics -fbacktrace)# -ffpe-trap=zero,overflow,underflow)
    if (MKL_FOUND)
        list(APPEND FFLAGS8-fdefault-integer-8 -m64)
    endif()
elseif(${CMAKE_Fortran_COMPILER_ID} STREQUAL PGI)

elseif(${CMAKE_Fortran_COMPILER_ID} STREQUAL Flang)
  list(APPEND CXXLIBS)  # Not needed:  stdc++ c++abi   Don't use: -stdlib=libc++
  list(APPEND FFLAGS -Mallocatable=03)
  list(APPEND FLIBS -static-flang-libs)
endif()


include(CheckFortranSourceCompiles)
check_fortran_source_compiles("program es; error stop; end" f2008
                              SRC_EXT f90)
