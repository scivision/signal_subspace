project('spectrum', 'c', 'cpp', 'fortran',
version: '1.1.1',
default_options : ['cpp_std=c++11']
)

fc = meson.get_compiler('fortran')

lapack = dependency('lapack', cmake_module_path: 'cmake/Modules', required: true)

subdir('src')

fespritcmpl = executable('f_esprit_cmpl', 'test/RunSubspace.f90', link_with : subspace)
test('ComplexEsprit', fespritcmpl, timeout: 30)

fespritreal = executable('f_esprit_real', 'test/RunSubspace_realsp.f90', link_with : subspace)
test('Real Esprit', fespritreal, timeout: 30)

cesprit = executable('c_esprit', 'test/cSubspace.c', link_with : subspace)
test('C Esprit', cesprit, timeout: 30)

cppesprit = executable('cpp_esprit', 'test/cppSubspace.cpp', link_with : subspace)

test('C++Esprit', cppesprit, timeout: 30)
