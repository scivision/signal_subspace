=================
spectral_analysis
=================
1-D and ensemble signal analysis

Compile ESPRIT example with noisy sinusoid
==========================================
::
  
   gfortran -Wall -O3 -march=native -fexternal-blas perf.f90 signals.f90 subspace.f90 RunSubspace.f90 -lblas -llapack -pedantic -o test_esprit

   ./test_esprit
