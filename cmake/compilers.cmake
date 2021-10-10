include(CheckSourceCompiles)

if(CMAKE_Fortran_COMPILER_ID MATCHES "^Intel")
  add_compile_options(
  $<IF:$<BOOL:${WIN32}>,/QxHost,-xHost>
  "$<$<COMPILE_LANGUAGE:Fortran>:-traceback;-heap-arrays>"
  "$<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<CONFIG:Debug>>:-check all;-fpe0;-warn;-traceback;-debug extended>"
  )
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
  add_compile_options(
  "$<$<COMPILE_LANGUAGE:Fortran>:-fimplicit-none;-Werror=array-bounds>"
  "$<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<CONFIG:Debug>>:-ffpe-trap=zero,overflow,underflow>"
  -mtune=native -Wall -Wextra
  )
endif()



check_source_compiles(Fortran
  "program test
  call random_init(.false., .false.)
  end program"
  f18random)
