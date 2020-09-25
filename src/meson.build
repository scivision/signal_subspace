conf_data = configuration_data()
if fc.links('call random_init(.false., .false.); end', name: 'F2018 random_init')
  conf_data.set('_random_init', 'call random_init(repeatable, image_distinct)')
else
  conf_data.set('_random_init', 'call random_seed()')
endif
comm_src = configure_file(input : 'comm.in.f90',
output : 'comm.f90',
configuration : conf_data)

subspace = library('subspace',
  sources: ['filters.f90', 'covariance.f90', 'subspace.f90', 'signals.f90', 'perf.f90', comm_src],
  dependencies : lapack)
