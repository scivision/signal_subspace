if(CMAKE_Fortran_COMPILER_ID MATCHES "^Intel")
  add_compile_options(
  "$<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<CONFIG:Debug>>:-check all;-fpe0;-warn;-traceback;-debug extended>"
  )
  if(NOT CMAKE_CROSSCOMPILING)
    add_compile_options($<IF:$<BOOL:${WIN32}>,/QxHost,-xHost>)
  endif()
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  add_compile_options(
  "$<$<COMPILE_LANGUAGE:Fortran>:-fimplicit-none;-Werror=array-bounds>"
  "$<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<CONFIG:Debug>>:-ffpe-trap=zero,overflow,underflow>"
  -Wall -Wextra
  )
  if(NOT CMAKE_CROSSCOMPILING)
    add_compile_options(-mtune=native)
  endif()
endif()
