cmake_minimum_required (VERSION 3.7)
project(spectrum C CXX Fortran)
enable_testing()

option(USE_MKL "use Intel MKL")
# we build separate libraries for real and complex to avoid polymorphic performance hits and complexities.
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/Modules/)

include(cmake/math.cmake)
# *** DO NOT use -ffast-math *** it screws up the signaling between modules!!
include(cmake/compilers.cmake)

add_compile_options(${FLAGS})

add_library(subspace SHARED filters.f90 covariance.f90 subspace.f90 signals.f90 perf.f90)
if(f2008)
  target_sources(subspace PRIVATE comm.f90)
else()
  target_sources(subspace PRIVATE comm_legacy.f90)
endif()
target_link_libraries(subspace PRIVATE ${FLIBS})
target_compile_options(subspace PRIVATE ${FFLAGS})

#------ test program: Fortran Complex Double Precision ----------
add_executable(fespritcmpl RunSubspace.f90)
target_link_libraries(fespritcmpl subspace ${FLIBS})
target_compile_options(fespritcmpl PRIVATE ${FFLAGS})
add_test(NAME FortranComplexEsprit COMMAND fespritcmpl)
#------ test program: Fortran Real Single Precision -------------
add_executable(fespritreal RunSubspace_realsp.f90)
target_link_libraries(fespritreal subspace ${FLIBS})
target_compile_options(fespritreal PRIVATE ${FFLAGS})
add_test(NAME FortranRealEsprit COMMAND fespritreal)
#------ test program: C++ Real Single ---------------------------
add_executable(cppesprit cppSubspace.cpp)
target_link_libraries(cppesprit subspace ${CLIBS} ${CXXLIBS})
set_target_properties(cppesprit PROPERTIES CXX_STANDARD 11)
add_test(NAME C++Esprit COMMAND cppesprit)
#------ test program: C Real Single -----------------------------
add_executable(cesprit cSubspace.c)
target_link_libraries(cesprit subspace ${CLIBS})
set_target_properties(cesprit PROPERTIES C_STANDARD 11)
add_test(NAME C-Esprit COMMAND cesprit)


#-------------------------------------------------------------------------------

# ------ mkl manual working --  NOTE: -Wl,--no-as-need prevents runtime errors
# gfortran -fdefault-integer-8 -g -I$MKLROOT/include/intel64/ilp64 -m64  -I$MKLROOT/include ../comm.f90 ../perf.f90 ../covariance.f90 ../subspace.f90 ../signals.f90 ../RunSubspace.f90 -L$MKLROOT/lib/intel64 -lmkl_blas95_ilp64 -lmkl_lapack95_ilp64 -lmkl_gf_ilp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl && ./a.out

# OpenBLAS gfortran Complex64 WORKING
# gfortran ../comm.f90 ../perf.f90 ../covariance.f90 ../subspace.f90 ../signals.f90 ../RunSubspace.f90 -lblas -llapack -lpthread -lm  && ./a.out
#
# MKL gfortran Real32 WORKING
# gfortran ../comm.f90 ../perf.f90 ../covariance_realsp.f90 ../subspace_realsp.f90 ../signals_realsp.f90 ../filters.f90  ../RunSubspace_realsp.f90 -lmkl_blas95_lp64 -lmkl_lapack95_lp64 -lmkl_gf_lp64 -lmkl_sequential -lmkl_core -ldl -lm  && ./a.out
#
# not working 8-byte integer Parameter 13 SGESVD
# ifort -i8 -I${F95ROOT}/include/intel64/ilp64 -I${MKLROOT}/include  ../comm.f90 ../perf.f90 ../covariance_realsp.f90 ../subspace_realsp.f90 ../signals_realsp.f90 ../filters.f90  ../RunSubspace_realsp.f90 ${MKLROOT}/lib/intel64/libmkl_blas95_ilp64.a ${MKLROOT}/lib/intel64/libmkl_lapack95_ilp64.a -L${MKLROOT}/lib/intel64 -Wl,--no-as-needed -lmkl_gf_ilp64 -lmkl_sequential -lmkl_core -lpthread -ldl -lm  && ./a.out
#
#
# ifort -I${F95ROOT}/include/intel64/lp64 -I${MKLROOT}/include  ../comm.f90 ../perf.f90 ../covariance_realsp.f90 ../subspace_realsp.f90 ../signals_realsp.f90 ../filters.f90  ../RunSubspace_realsp.f90 ${MKLROOT}/lib/intel64/libmkl_blas95_lp64.a ${MKLROOT}/lib/intel64/libmkl_lapack95_lp64.a -L${MKLROOT}/lib/intel64 -lmkl_gf_lp64 -lmkl_sequential -lmkl_core -lpthread -ldl -lm  && ./a.out


#---- intel compiler
# note that you can compile first with GCC then link with ICPC (kind of silly 
# since main computation is done in Fortran, but just to show the concept)
# cmake ..
# make
# icpc ../cppSubspace.cpp libsubspace_real.a -lgfortran -llapack

# using Intel Compiler requires linking:
# svml intlc ifcore imf
# that do not work for GCC
# 
# cd bin
# rm -r *
# FC=ifort CC=icc CXX=icpc cmake ..
# make
# icpc ../cppSubspace.cpp libsubspace_real.a -lifcore -lsvml -lintlc -limf


