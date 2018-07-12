cmake_minimum_required (VERSION 3.7)
project(spectrum C CXX Fortran)
enable_testing()

if(CMAKE_BUILD_TYPE STREQUAL Debug)
  add_compile_options(-g -O0)
else()
  add_compile_options(-O3)
endif()

#------------ subspace library ---------------
# we build separate libraries for real and complex to avoid polymorphic performance hits and complexities.
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/Modules/)
#find_package(MKL)
if(MKL_FOUND)
    set(MKLROOT $ENV{MKLROOT})
    include_directories(${MKL_INCLUDE_DIRS})
    # Sequential
#    list(APPEND FLIBS mkl_blas95_lp64 mkl_lapack95_lp64 mkl_gf_lp64 mkl_sequential mkl_core pthread dl m)
#    list(APPEND FLIBS8 mkl_blas95_ilp64 mkl_lapack95_ilp64 mkl_gf_ilp64 mkl_sequential mkl_core pthread dl m)
    # TBB
    list(APPEND FLIBS mkl_blas95_lp64 mkl_lapack95_lp64 mkl_gf_lp64 mkl_tbb_thread mkl_core tbb stdc++ pthread dl m)
#    list(APPEND FLIBS8 mkl_blas95_ilp64 mkl_lapack95_ilp64 mkl_gf_ilp64 mkl_tbb_thread mkl_core tbb stdc++ pthread dl m)
    # OpenMP
#    list(APPEND FLIBS mkl_blas95_lp64 mkl_lapack95_lp64 mkl_gf_lp64 mkl_intel_thread mkl_core iomp5 pthread dl m)
#    list(APPEND FLIBS8 mkl_blas95_ilp64 mkl_lapack95_ilp64 mkl_gf_ilp64 mkl_intel_thread mkl_core iomp5 pthread dl m)
else()
    find_package(ATLAS)
    if(ATLAS_FOUND)
        list(APPEND FLIBS ${Atlas_LAPACK_LIBRARY})
    else()
        find_package(LAPACK REQUIRED) 
        list(APPEND FLIBS ${LAPACK_LIBRARIES})
    endif()
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
  list(APPEND FFLAGS -Mallocatable=03)
elseif(${CMAKE_Fortran_COMPILER_ID} STREQUAL Flang)
  list(APPEND CXXLIBS)  # Not needed:  stdc++ c++abi   Don't use: -stdlib=libc++
  list(APPEND FFLAGS -Mallocatable=03)
  list(APPEND FLIBS -static-flang-libs)
endif()


# *** DO NOT use -ffast-math *** it screws up the signaling between modules!!


add_compile_options(${FLAGS})

#------------------------------------------------------------------------------------------------
set(okcomp GNU Intel)
if(CMAKE_Fortran_COMPILER_ID IN_LIST okcomp)
  add_library(comm comm.f90 perf.f90)
else()
  add_library(comm comm_legacy.f90 perf.f90)
endif()
target_compile_options(comm PRIVATE ${FFLAGS})
set_target_properties(comm PROPERTIES POSITION_INDEPENDENT_CODE ON)

add_library(subspace filters.f90 covariance.f90 subspace.f90 signals.f90)
target_link_libraries(subspace PRIVATE comm ${FLIBS})
set_target_properties(subspace PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_compile_options(subspace PRIVATE ${FFLAGS} ${FFLAGS8})

#------ test program: Fortran Complex Double Precision ----------
add_executable(fespritcmpl RunSubspace.f90)
target_link_libraries(fespritcmpl subspace)
target_compile_options(fespritcmpl PRIVATE ${FFLAGS})
add_test(NAME FortranComplexEsprit COMMAND fespritcmpl)
#------ test program: Fortran Real Single Precision -------------
add_executable(fespritreal RunSubspace_realsp.f90)
target_link_libraries(fespritreal subspace)
target_compile_options(fespritreal PRIVATE ${FFLAGS})
add_test(NAME FortranRealEsprit COMMAND fespritreal)
#------ test program: C++ Real Single ---------------------------
add_executable(cppesprit cppSubspace.cpp)
target_link_libraries(cppesprit subspace ${CLIBS} ${CXXLIBS})
set_target_properties(cppesprit PROPERTIES CXX_STANDARD 14)
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


