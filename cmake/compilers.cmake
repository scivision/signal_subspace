if(CMAKE_Fortran_COMPILER_ID STREQUAL Intel)
    set(CMAKE_Fortran_FLAGS_DEBUG "-check all -fpe0 -warn -traceback -debug extended ")

    if(WIN32)
      set(CMAKE_Fortran_FLAGS "/warn:declarations /heap-arrays ")
    else()
      set(CMAKE_Fortran_FLAGS "-warn declarations ")
    endif()
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
  if(CMAKE_Fortran_COMPILER_VERSION VERSION_GREATER_EQUAL 8)
    string(APPEND CMAKE_Fortran_FLAGS "-std=f2018 ")
  endif()

  string(APPEND CMAKE_Fortran_FLAGS "-fimplicit-none -Werror=array-bounds ")
  string(APPEND CMAKE_Fortran_FLAGS_DEBUG "-ffpe-trap=zero,overflow,underflow ")

  add_compile_options(-mtune=native -Wall -Wextra)
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL PGI)
  set(CMAKE_Fortran_FLAGS "-Mdclchk ")
endif()


include(CheckFortranSourceCompiles)
check_fortran_source_compiles("call random_init(.false., .false.); end" f2018
                              SRC_EXT f90)
