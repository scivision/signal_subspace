if(f18random)
  set(_random_init "call random_init(repeatable, image_distinct)")
else()
  set(_random_init "call random_seed()")
endif()

configure_file(comm.in.f90 comm.f90)

add_library(subspace OBJECT filters.f90 covariance.f90 subspace.f90 signals.f90 perf.f90
  ${CMAKE_CURRENT_BINARY_DIR}/comm.f90)
target_link_libraries(subspace PRIVATE LAPACK::LAPACK)
set_target_properties(subspace PROPERTIES Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include)
target_include_directories(subspace INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/include)

add_library(subspace::subspace ALIAS subspace)
