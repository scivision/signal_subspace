add_library(subspace OBJECT filters.f90 covariance.f90 subspace.f90 signals.f90 perf.f90)
if(f2018random_init)
  target_sources(subspace PRIVATE comm.f90)
else()
  target_sources(subspace PRIVATE comm_legacy.f90)
endif()
target_link_libraries(subspace PRIVATE ${LAPACK_LIBRARIES})

#------ test program: Fortran Complex Double Precision ----------
add_executable(f_esprit_cmpl RunSubspace.f90)
target_link_libraries(f_esprit_cmpl subspace)
add_test(NAME fortranComplexEsprit COMMAND f_esprit_cmpl)
#------ test program: Fortran Real Single Precision -------------
add_executable(f_esprit_real RunSubspace_realsp.f90)
target_link_libraries(f_esprit_real subspace)
add_test(NAME fortranRealEsprit COMMAND f_esprit_real)
#------ test program: C++ Real Single ---------------------------
include(CheckLanguage)
check_language(CXX)
if(CMAKE_CXX_COMPILER)
  enable_language(CXX)

  add_executable(cpp_esprit cppSubspace.cpp)
  target_link_libraries(cpp_esprit subspace)
  target_compile_features(cpp_esprit PRIVATE cxx_std_11)

  add_test(NAME C++_Esprit COMMAND cpp_esprit)
endif()
#------ test program: C Real Single -----------------------------
add_executable(c_esprit cSubspace.c)
target_link_libraries(c_esprit subspace)
target_compile_features(c_esprit PRIVATE c_std_11)
set_target_properties(c_esprit PROPERTIES LINKER_LANGUAGE C)  # necessary for PGI
add_test(NAME C_esprit COMMAND c_esprit)
