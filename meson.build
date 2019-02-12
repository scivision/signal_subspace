project('spectrum', 'c', 'cpp', 'fortran', default_options : ['default_library=static'])

fc = meson.get_compiler('fortran')

lapack = fc.find_library('lapack', required : true)

subspace = library('subspace', 'filters.f90', 'covariance.f90', 'subspace.f90', 'signals.f90', 'perf.f90', 'comm.f90', dependencies : lapack)

fespritcmpl = executable('fespritcmpl', 'RunSubspace.f90', link_with : subspace)
test('Complex Esprit', fespritcmpl)

fespritreal = executable('fespritreal', 'RunSubspace_realsp.f90', link_with : subspace)
test('Real Esprit', fespritreal)

cppesprit = executable('cppesprit', 'cppSubspace.cpp', link_with : subspace)
test('C++ Esprit', cppesprit)

cesprit = executable('cesprit', 'cSubspace.c', link_with : subspace)
test('C Esprit', cesprit)

