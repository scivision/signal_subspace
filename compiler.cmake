#this is a Cmake>=3.3 template, loaded with include(compiler.cmake) from your main CMakeLists.txt
add_compile_options(-mtune=native -Wall -Wextra -Wpedantic -fexceptions)

if (NOT CYGWIN)
    add_compile_options(-fstack-protector-all)
endif()

set(fortran_flags -std=f2008)


#-Warray-temporaries -Winteger-division -funroll-loops

if (${CMAKE_CXX_COMPILER_ID} STREQUAL Clang)
    list(APPEND ccxx_flags -Weverything -Werror=array-bounds -Wno-c++98-compat)
elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL GNU)
    list(APPEND ccxx_flags -Warray-bounds=2)
elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL Intel)
    list(APPEND ccxx_flags -check bounds -fpe0 -traceback)
endif()

if(${CMAKE_Fortran_COMPILER_ID} STREQUAL GNU)
    list(APPEND fortran_flags -fbacktrace -Warray-bounds=2)
elseif(${CMAKE_Fortran_COMPILER_ID} STREQUAL Intel)
    list(APPEND fortran_flags -traceback -fpe0)
elseif(${CMAKE_Fortran_COMPILER_ID} STREQUAL PGI)
    list(APPEND fortran_flags -traceback)
endif()

add_compile_options( # Cmake >=3.3 for COMPILE_LANGUAGE
    "$<$<COMPILE_LANGUAGE:C>:${ccxx_flags}>"
    "$<$<COMPILE_LANGUAGE:CXX>:${ccxx_flags}>"
    "$<$<COMPILE_LANGUAGE:Fortran>:${fortran_flags}>"
)

# https://gcc.gnu.org/onlinedocs/gcc-5.3.0/gcc/Debugging-Options.html
if(CMAKE_BUILD_TYPE MATCHES Debug)
#    add_compile_options(-fsanitize=address)
endif()

# Intel MKL is 2-3 times faster than Lapack and 2016 (v11.3) now no cost:
# https://software.intel.com/en-us/articles/free_mkl
# source /opt/intel/mkl/bin/mklvars.sh intel64
# gfortran  myfile.f90  -Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_gf_lp64.a ${MKLROOT}/lib/intel64/libmkl_core.a ${MKLROOT}/lib/intel64/libmkl_sequential.a -Wl,--end-group -I${MKLROOT}/include/intel64/lp64 -m64 -I${MKLROOT}/include -L${MKLROOT}/lib/intel64 -lmkl_gf_ilp64 -lmkl_gf_lp64 -lmkl_intel_ilp64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential -lpthread -lmkl_rt -lm -ldl 
