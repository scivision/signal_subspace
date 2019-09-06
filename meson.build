project('spectrum', 'c', 'fortran',
  default_options : ['default_library=static', 'buildtype=release'])

fc = meson.get_compiler('fortran')

lapack = dependency('lapack', cmake_module_path: 'cmake/Modules', required: false)
if not lapack.found()
  lapack_proj = subproject('lapack')
  lapack = lapack_proj.get_variable('lapack')
endif

subspace = library('subspace', 'filters.f90', 'covariance.f90', 'subspace.f90', 'signals.f90', 'perf.f90', 'comm.f90', dependencies : lapack)

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
