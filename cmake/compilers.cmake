if(CMAKE_Fortran_COMPILER_ID MATCHES "^Intel")
  set(fopts
  "$<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<CONFIG:Debug>>:-check all;-fpe0;-warn;-traceback;-debug extended>"
  )
  if(NOT CMAKE_CROSSCOMPILING)
    add_compile_options($<IF:$<BOOL:${WIN32}>,/QxHost,-xHost>)
  endif()
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  set(fopts
  "$<$<COMPILE_LANGUAGE:Fortran>:-fimplicit-none;-Werror=array-bounds>"
  "$<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<CONFIG:Debug>>:-ffpe-trap=zero,overflow,underflow>"
  -Wall -Wextra
  )
  if(NOT CMAKE_CROSSCOMPILING)
    add_compile_options(-mtune=native)
  endif()
endif()
