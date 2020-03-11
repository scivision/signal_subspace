if fc.links('call random_init(.false., .false.); end', name: 'F2018 random_init')
  comm_src = 'comm.f90'
else
  comm_src = 'comm_legacy.f90'
endif

subspace = library('subspace',
  sources: ['filters.f90', 'covariance.f90', 'subspace.f90', 'signals.f90', 'perf.f90', comm_src],
  dependencies : lapack)