=================
spectral_analysis
=================
1-D and ensemble signal analysis

based in part upon the `Spectral Analysis Lib public domain code <https://github.com/vincentchoqueuse/spectral_analysis_project>`_

Compile Fortran ESPRIT to use from Python via f2py
==================================================
::

   f2py3 --quiet -m fortsubspace -c subspace.f90

Compile ESPRIT example with noisy sinusoid
==========================================
::
  
   gfortran -Wall -O3 -march=native -fexternal-blas perf.f90 signals.f90 subspace.f90 RunSubspace.f90 -lblas -llapack -pedantic -o test_esprit

   ./test_esprit
