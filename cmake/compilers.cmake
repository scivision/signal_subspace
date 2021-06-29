include(CheckSourceCompiles)

if(CMAKE_Fortran_COMPILER_ID MATCHES Intel)
  if(WIN32)
    add_compile_options(/QxHost)
    string(APPEND CMAKE_Fortran_FLAGS " /warn:declarations /heap-arrays")
  else()
    add_compile_options(-xHost)
    string(APPEND CMAKE_Fortran_FLAGS " -warn declarations")
    string(APPEND CMAKE_Fortran_FLAGS_DEBUG " -check all -fpe0 -warn -traceback -debug extended")
  endif()
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
  string(APPEND CMAKE_Fortran_FLAGS " -fimplicit-none -Werror=array-bounds")
  string(APPEND CMAKE_Fortran_FLAGS_DEBUG " -ffpe-trap=zero,overflow,underflow")
  # mtune=native for better cross-platform
  add_compile_options(-mtune=native -Wall -Wextra)
endif()



check_source_compiles(Fortran
  "program test
  call random_init(.false., .false.)
  end program"
  f18random)
