add_library(subspace OBJECT filters.f90 covariance.f90 subspace.f90 signals.f90 perf.f90)
if(f2018random_init)
  target_sources(subspace PRIVATE comm.f90)
else()
  target_sources(subspace PRIVATE comm_legacy.f90)
endif()
target_link_libraries(subspace PRIVATE ${LAPACK_LIBRARIES})

#------ test program: Fortran Complex Double Precision ----------
add_executable(fespritcmpl RunSubspace.f90)
target_link_libraries(fespritcmpl subspace)
add_test(NAME fortranComplexEsprit COMMAND fespritcmpl)
#------ test program: Fortran Real Single Precision -------------
add_executable(fespritreal RunSubspace_realsp.f90)
target_link_libraries(fespritreal subspace)
add_test(NAME fortranRealEsprit COMMAND fespritreal)
#------ test program: C++ Real Single ---------------------------
include(CheckLanguage)
check_language(CXX)
if(CMAKE_CXX_COMPILER)
  enable_language(CXX)

  add_executable(cppesprit cppSubspace.cpp)
  target_link_libraries(cppesprit subspace)
  set_target_properties(cppesprit PROPERTIES CXX_STANDARD 11)

  add_test(NAME c++Esprit COMMAND cppesprit)
endif()
#------ test program: C Real Single -----------------------------
add_executable(cesprit cSubspace.c)
target_link_libraries(cesprit subspace)
set_target_properties(cesprit PROPERTIES
  C_STANDARD 11
  LINKER_LANGUAGE C)  # necessary for PGI
add_test(NAME cEsprit COMMAND cesprit)
