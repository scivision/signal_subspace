add_library(subspace OBJECT filters.f90 covariance.f90
subspace.f90 $<IF:$<BOOL:${LAPACK_z_FOUND}>,subspace_complex.f90,subspace_dummy.f90>
signals.f90 perf.f90
comm.f90
)
target_compile_options(subspace PRIVATE ${fopts})
target_link_libraries(subspace PRIVATE LAPACK::LAPACK)
set_property(TARGET subspace PROPERTY Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include)
target_include_directories(subspace INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/include)
