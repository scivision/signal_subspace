
if(USE_MKL)
  set(BLA_VENDOR Intel10_64lp)
  find_package(LAPACK REQUIRED)
else()
  set(BLA_VENDOR ATLAS)
  find_package(LAPACK)

  if(NOT LAPACK_FOUND)
    unset(BLA_VENDOR)
    find_package(LAPACK REQUIRED)
  endif()
  
endif()

list(APPEND FLIBS ${LAPACK_LIBRARIES})



# Sequential
#    list(APPEND FLIBS mkl_blas95_lp64 mkl_lapack95_lp64 mkl_gf_lp64 mkl_sequential mkl_core pthread dl m)
#    list(APPEND FLIBS8 mkl_blas95_ilp64 mkl_lapack95_ilp64 mkl_gf_ilp64 mkl_sequential mkl_core pthread dl m)
# TBB (WORKS)
#list(APPEND FLIBS mkl_blas95_lp64 mkl_lapack95_lp64 mkl_gf_lp64 mkl_tbb_thread mkl_core tbb stdc++ pthread dl m)
#    list(APPEND FLIBS8 mkl_blas95_ilp64 mkl_lapack95_ilp64 mkl_gf_ilp64 mkl_tbb_thread mkl_core tbb stdc++ pthread dl m)
# OpenMP
#    list(APPEND FLIBS mkl_blas95_lp64 mkl_lapack95_lp64 mkl_gf_lp64 mkl_intel_thread mkl_core iomp5 pthread dl m)
#    list(APPEND FLIBS8 mkl_blas95_ilp64 mkl_lapack95_ilp64 mkl_gf_ilp64 mkl_intel_thread mkl_core iomp5 pthread dl m)
