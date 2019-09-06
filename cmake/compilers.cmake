

if(CMAKE_Fortran_COMPILER_ID STREQUAL Intel)
    list(APPEND CLIBS ifcoremt imf svml intlc)
    if(CMAKE_BUILD_TYPE STREQUAL Debug)
      list(APPEND FFLAGS -check all -fpe0 -warn -traceback -debug extended)
    endif()

    if(WIN32)
      list(APPEND FFLAGS /warn:declarations /heap-arrays)
    else()
      list(APPEND FFLAGS -warn declarations -heap-arrays)
    endif()
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
  if(CMAKE_Fortran_COMPILER_VERSION VERSION_GREATER_EQUAL 8)
    list(APPEND FFLAGS -std=f2018)
  endif()
    list(APPEND FFLAGS -fimplicit-none)

    list(APPEND FLAGS -mtune=native -Wall -Werror=array-bounds
            -Wextra -Wpedantic -fexceptions)
    #list(APPEND FFLAGS  -ffpe-trap=zero,overflow,underflow)

elseif(CMAKE_Fortran_COMPILER_ID STREQUAL PGI)
  list(APPEND FFLAGS -Mdclchk)
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL Flang)

endif()


include(CheckFortranSourceCompiles)
check_fortran_source_compiles("call random_init(.false., .false.); end" f2018
                              SRC_EXT f90)

if(CMAKE_Fortran_COMPILER_ID STREQUAL Intel)
  find_package(LAPACK REQUIRED COMPONENTS MKL)
else()
  find_package(LAPACK REQUIRED)
endif()