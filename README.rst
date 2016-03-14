=================
spectral_analysis
=================
1-D and ensemble signal analysis

based in part upon the `Spectral Analysis Lib public domain code <https://github.com/vincentchoqueuse/spectral_analysis_project>`_

Compile Fortran ESPRIT to use from Python via f2py
==================================================
To be able to access the Fortran Esprit from Python::

   f2py3 --quiet -m fortsubspace -c subspace.f90

If you get ImportError complaining about gfortran 1_4, see notes at bottom of this section.

Then in the Python script::

   import numpy as np
   from fortsubspace.subspace import esprit

   fs=48e3; F=1000 #arbitrary
   t = np.arange(0,0.01,1/fs)
   x = np.exp(1j*2*np.pi*F*t) + np.random.randn(t.size)
   fest,sigma=esprit(x,1,fs)

Fest will be very close to 1000 Hz.

Notes if ImportError
--------------------
If you're using Gfortran 5.x, you may get errors with regard to Fortran library version,
since at the moment Numpy uses Gfortran 4.x.

Try compiling with::

    f2py3 --f90exec=gfortran-4.9 --quiet -m fortsubspace -c subspace.f90

If it still complains about library version, try::

    ln -s /usr/lib/gcc/x86_64-linux-gnu/4.9/libgfortran.so libgfortran.so.3


Compile ESPRIT example with noisy sinusoid
==========================================
Note, don't use -Ofast to avoid seg faults.::
  
   gfortran -Wall -pedantic -O3 -march=native -fexternal-blas perf.f90 signals.f90 subspace.f90 RunSubspace.f90 -lblas -llapack -lpthread

   ./test_esprit
