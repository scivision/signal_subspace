cmake_minimum_required (VERSION 2.8.12)
project(spectrum C CXX Fortran)

#------------ subspace library ---------------
# we build separate libraries for real and complex to avoid polymorphic performance hits and complexities.
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")
#find_package(MKL)
if(MKL_FOUND)
    set(MKLROOT $ENV{MKLROOT})
    include_directories(${MKL_INCLUDE_DIRS})
    # Sequential
#    set(FLIBS ${FLIBS} mkl_blas95_lp64 mkl_lapack95_lp64 mkl_gf_lp64 mkl_sequential mkl_core pthread dl m)
#    set(FLIBS8 ${FLIBS8} mkl_blas95_ilp64 mkl_lapack95_ilp64 mkl_gf_ilp64 mkl_sequential mkl_core pthread dl m)
    # TBB
    set(FLIBS ${FLIBS} mkl_blas95_lp64 mkl_lapack95_lp64 mkl_gf_lp64 mkl_tbb_thread mkl_core tbb stdc++ pthread dl m)
    set(FLIBS8 ${FLIBS8} mkl_blas95_ilp64 mkl_lapack95_ilp64 mkl_gf_ilp64 mkl_tbb_thread mkl_core tbb stdc++ pthread dl m)
    # OpenMP
#    set(FLIBS ${FLIBS} mkl_blas95_lp64 mkl_lapack95_lp64 mkl_gf_lp64 mkl_intel_thread mkl_core iomp5 pthread dl m)
#    set(FLIBS8 ${FLIBS8} mkl_blas95_ilp64 mkl_lapack95_ilp64 mkl_gf_ilp64 mkl_intel_thread mkl_core iomp5 pthread dl m)
else()
    find_package(ATLAS)
    if(ATLAS_FOUND)
        set(FLIBS ${FLIBS}  ${Atlas_LAPACK_LIBRARY}) 
        set(FLIBS8 ${FLIBS8} ${Atlas_LAPACK_LIBRARY}) 
    else()
        find_package(LAPACK REQUIRED) 
        set(FLIBS ${FLIBS}  lapack) 
        set(FLIBS8 ${FLIBS8} lapack) 

    endif()
endif()

if(${CMAKE_Fortran_COMPILER_ID} STREQUAL "Intel")
    set(CLIBS ${CLIBS} ifcoremt imf svml intlc)
    set(FFLAGS ${FFLAGS} -check all -fpe0 -warn -traceback -debug extended)
    if (MKL_FOUND)
        set(FFLAGS8 ${FFLAGS8} -i8)
    endif()
else() # gfortran
# NOTE: -fdefault-integer-8 -m64  are crucial for MKL using gfortran to avoid SIGSEGV at runtime!
    set(FLAGS ${FLAGS} -Wall -Werror=array-bounds -Wextra -Wpedantic -fexceptions)
    set(FFLAGS ${FFLAGS} -fall-intrinsics -std=f2008ts -fbacktrace)# -ffpe-trap=zero,overflow,underflow)
    if (MKL_FOUND)
        set(FFLAGS8 ${FFLAGS8} -fdefault-integer-8 -m64)
    endif()
endif()

# *** DO NOT use -ffast-math *** it screws up the signaling between modules!!
add_compile_options(-mtune=native -O3 -g ${FLAGS})

#------------------------------------------------------------------------------------------------
add_library(comm comm.f90 perf.f90)
target_compile_options(comm PRIVATE ${FFLAGS})


add_library(subspace_cmpl covariance.f90 subspace.f90 signals.f90)
target_link_libraries(subspace_cmpl PRIVATE comm ${FLIBS8})
set_target_properties(subspace_cmpl PROPERTIES Fortran_MODULE_DIRECTORY mod.cmpl)
target_compile_options(subspace_cmpl PRIVATE ${FFLAGS} ${FFLAGS8})

add_library(subspace_real comm.f90 filters.f90 covariance_realsp.f90 subspace_realsp.f90 signals_realsp.f90)
target_link_libraries(subspace_real PRIVATE comm ${FLIBS})
set_target_properties(subspace_real PROPERTIES Fortran_MODULE_DIRECTORY mod.real)
target_compile_options(subspace_real PRIVATE ${FFLAGS})

#------ test program: Fortran Complex Double Precision ----------
add_executable(fespritcmpl RunSubspace.f90)
target_link_libraries(fespritcmpl subspace_cmpl)
set_target_properties(fespritcmpl PROPERTIES Fortran_MODULE_DIRECTORY mod.cmpl)
target_compile_options(fespritcmpl PUBLIC ${FFLAGS})
#------ test program: Fortran Real Single Precision -------------
add_executable(fespritreal RunSubspace_realsp.f90)
target_link_libraries(fespritreal subspace_real)
set_target_properties(fespritreal PROPERTIES Fortran_MODULE_DIRECTORY mod.real)
target_compile_options(fespritreal PUBLIC ${FFLAGS})
#------ test program: C++ Real Single ---------------------------
add_executable(cppesprit cppSubspace.cpp)
target_link_libraries(cppesprit subspace_real ${CLIBS})
set_target_properties(cppesprit PROPERTIES CXX_STANDARD 14)
#------ test program: C Real Single -----------------------------
add_executable(cesprit cSubspace.c)
target_link_libraries(cesprit subspace_real ${CLIBS})
set_target_properties(cesprit PROPERTIES C_STANDARD 11)



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


