project('spectrum', 'c', 'fortran',
  default_options : ['default_library=static', 'buildtype=release', 'warning_level=3'])

fc = meson.get_compiler('fortran')

lapack = dependency('lapack', cmake_module_path: 'cmake/Modules', required: false)
if not lapack.found()
  lapack_proj = subproject('lapack')
  lapack = lapack_proj.get_variable('lapack')
endif

if fc.links('call random_init(.false., .false.); end', name: 'F2018 random_init')
  comm_src = 'comm.f90'
else
  comm_src = 'comm_legacy.f90'
endif

subspace = library('subspace',
  sources: ['filters.f90', 'covariance.f90', 'subspace.f90', 'signals.f90', 'perf.f90', comm_src],
  dependencies : lapack)

fespritcmpl = executable('fespritcmpl', 'RunSubspace.f90', link_with : subspace)
test('Complex Esprit', fespritcmpl, timeout: 30)

fespritreal = executable('fespritreal', 'RunSubspace_realsp.f90', link_with : subspace)
test('Real Esprit', fespritreal, timeout: 30)

cesprit = executable('cesprit', 'cSubspace.c', link_with : subspace)
test('C Esprit', cesprit, timeout: 30)

if add_languages('cpp', required: false)
  cppesprit = executable('cppesprit', 'cppSubspace.cpp', link_with : subspace)
  test('C++ Esprit', cppesprit, timeout: 30)
endif
