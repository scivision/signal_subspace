cmake_minimum_required (VERSION 2.8.12)
project(spectrum C CXX Fortran)

#------------ subspace library ---------------
# we build separate libraries for real and complex to avoid polymorphic performance hits and complexities.
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")
#find_package(MKL)
if(MKL_FOUND)
    set(MKLROOT $ENV{MKLROOT})
    include_directories(${MKL_INCLUDE_DIRS} ${MKLROOT}/include/intel64/ilp64)
    set(FLIBS ${FLIBS} ${MKLROOT}/lib/intel64/libmkl_blas95_lp64.a ${MKLROOT}/lib/intel64/libmkl_lapack95_ilp64.a ${MKL_LIBRARIES} dl m)
else()
    find_package(BLAS REQUIRED)
    find_package(LAPACK REQUIRED) #or other math library providing the linear algebra e.g. MKL
    set(FLIBS ${FLIBS} blas lapack) 
endif()

if(${CMAKE_Fortran_COMPILER_ID} STREQUAL "Intel")
    link_libraries(ifcoremt imf svml intlc)
    set(FFLAGS ${FFLAGS} -check all -fpe0 -warn -traceback -debug extended)
    if (MKL_FOUND)
        set(FFLAGS ${FFLAGS} -i8)
    endif()
else() # gfortran
# NOTE: -fdefault-integer-8 -m64  are crucial for MKL using gfortran to avoid SIGSEGV at runtime!
    set(FLAGS ${FLAGS} -Wall -Werror=array-bounds -Wextra -Wpedantic -fexceptions)
    set(FFLAGS ${FFLAGS} -fall-intrinsics -std=f2008ts -fbacktrace -ffpe-trap=zero,overflow,underflow)
    if (MKL_FOUND)
        set(FFLAGS ${FFLAGS} -fdefault-integer-8 -m64)
    endif()
endif()

# *** DO NOT use -ffast-math *** it screws up the signaling between modules!!
add_compile_options(-mtune=native -g ${FLAGS})

#------------------------------------------------------------------------------------------------
add_library(subspace_cmpl comm.f90             covariance.f90 subspace.f90 signals.f90)
target_link_libraries(subspace_cmpl ${FLIBS})
set_target_properties(subspace_cmpl PROPERTIES Fortran_MODULE_DIRECTORY mod.cmpl)
target_compile_options(subspace_cmpl PRIVATE ${FFLAGS})

add_library(subspace_real comm.f90 filters.f90 covariance_realsp.f90 subspace_realsp.f90 signals_realsp.f90)
target_link_libraries(subspace_real ${FLIBS})
set_target_properties(subspace_real PROPERTIES Fortran_MODULE_DIRECTORY mod.real)
target_compile_options(subspace_real PRIVATE ${FFLAGS})

#------ test program: Fortran Complex Double Precision ----------
add_executable(fespritcmpl perf.f90  RunSubspace.f90)
target_link_libraries(fespritcmpl subspace_cmpl)
set_target_properties(fespritcmpl PROPERTIES Fortran_MODULE_DIRECTORY mod.cmpl)
target_compile_options(fespritcmpl PUBLIC ${FFLAGS})
#------ test program: Fortran Real Single Precision -------------
add_executable(fespritreal perf.f90 RunSubspace_realsp.f90)
target_link_libraries(fespritreal subspace_real)
set_target_properties(fespritreal PROPERTIES Fortran_MODULE_DIRECTORY mod.real)
target_compile_options(fespritreal PUBLIC ${FFLAGS})
#------ test program: C++ Real Single ---------------------------
add_executable(cppesprit cppSubspace.cpp)
target_link_libraries(cppesprit subspace_real)
set_target_properties(cppesprit PROPERTIES CXX_STANDARD 14)
#------ test program: C Real Single -----------------------------
add_executable(cesprit cSubspace.c)
target_link_libraries(cesprit subspace_real)
set_target_properties(cesprit PROPERTIES C_STANDARD 11)

# ------ mkl manual --
# gfortran -fdefault-integer-8 -I${F95ROOT}/include/intel64/ilp64 -m64 -I${MKLROOT}/include ../comm.f90 ../perf.f90 ../covariance.f90 ../subspace.f90 ../signals.f90 ../RunSubspace.f90 ${F95ROOT}/lib/intel64/libmkl_blas95_ilp64.a ${F95ROOT}/lib/intel64/libmkl_lapack95_ilp64.a -L${MKLROOT}/lib/intel64 -Wl,--no-as-needed -lmkl_gf_ilp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl
# -------- openblas manual
# gfortran ../comm.f90 ../perf.f90 ../covariance.f90 ../subspace.f90 ../signals.f90 ../RunSubspace.f90 -lblas -llapack -lpthread -lm 

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


