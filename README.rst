=================
spectral_analysis
=================
1-D and ensemble signal analysis

based in part upon the `Spectral Analysis Lib public domain code <https://github.com/vincentchoqueuse/spectral_analysis_project>`_

.. contents::

Fortran
=======


Compile ESPRIT example with noisy sinusoid
-------------------------------------------
Note, don't use -Ofast to avoid seg faults.::
  
   gfortran -Wall -pedantic -O3 -march=native -fexternal-blas perf.f90 signals.f90 subspace.f90 RunSubspace.f90 -lblas -llapack -lpthread

   ./test_esprit


C
=
Here is a simple example of calling Fortran code from C.
This program passes an integer from C to Fortran. Fortran converts the integer to float. Finally Fortan passes the float back to C for printing. 

1. Create .o Object files from each of C and Fortran
2. Link the object files with gcc

::

   gfortran -c cfort.f90 -o cfort.o
   gcc -c cfort.c -o main.o
   
   gcc main.o cfort.o -lgfortran

And you will observe 12345.00000 a float from 12345 the original integer.


Python
======

Compile Fortran ESPRIT to use from Python via f2py
--------------------------------------------------
To be able to access the Fortran Esprit from Python::

   f2py3 --quiet -m fortsubspace -c subspace.f90

See ``basic.py`` for a basic example.

If you get an ``ImportError`` complaining about gfortran 1_4, see notes at bottom of this section.


If you get ``ImportError``
---------------------------
If you're using Gfortran 5.x, you may get errors with regard to Fortran library version,
since at the moment Numpy uses Gfortran 4.x.

Try compiling with::

    f2py3 --f90exec=gfortran-4.9 --quiet -m fortsubspace -c subspace.f90

If it still complains about library version, try::

    ln -s /usr/lib/gcc/x86_64-linux-gnu/4.9/libgfortran.so libgfortran.so.3

