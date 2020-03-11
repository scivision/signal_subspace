project('spectrum', 'c', 'fortran',
  version: '1.0.3',
  default_options : ['default_library=static', 'buildtype=release', 'warning_level=3'])

fc = meson.get_compiler('fortran')

lapack = dependency('lapack', cmake_module_path: 'cmake/Modules', required: false)
if not lapack.found()
  lapack_proj = subproject('lapack')
  lapack = lapack_proj.get_variable('lapack')
endif

subdir('src')

fespritcmpl = executable('fespritcmpl', 'src/RunSubspace.f90', link_with : subspace)
test('Complex Esprit', fespritcmpl, timeout: 30)

fespritreal = executable('fespritreal', 'src/RunSubspace_realsp.f90', link_with : subspace)
test('Real Esprit', fespritreal, timeout: 30)

cesprit = executable('cesprit', 'src/cSubspace.c', link_with : subspace)
test('C Esprit', cesprit, timeout: 30)

if add_languages('cpp', required: false)
  cxx = meson.get_compiler('cpp')
  if cxx.compiles('''
#include <iostream>
int main(void) {}
''', name: 'C++ environment OK')
    cppesprit = executable('cppesprit', 'src/cppSubspace.cpp', link_with : subspace)

    test('C++ Esprit', cppesprit, timeout: 30)
  endif
endif
