target_sources(subspace PRIVATE filters.f90 covariance.f90
subspace.f90
"$<IF:$<BOOL:${LAPACK_z_FOUND}>,${CMAKE_CURRENT_SOURCE_DIR}/subspace_complex.f90,${CMAKE_CURRENT_SOURCE_DIR}/subspace_dummy.f90>"
signals.f90 perf.f90
comm.f90
)
