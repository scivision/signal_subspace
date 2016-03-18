=================
spectral_analysis
=================
1-D and ensemble signal analysis with subspace methods such as Esprit and RootMusic in Fortran, C, and Python

based in part upon the `Spectral Analysis Lib public domain code <https://github.com/vincentchoqueuse/spectral_analysis_project>`_

The core subspace code is written in Fortran 2008 and is called from other languages (Python, C).

.. contents::

Building
========
For all languages (Fortran, C, C++, Python) at once, simply type::

    make

If you wish to compile only for a particular language, see the optional individual sections below.


In the examples below, you will observe the frequency estimates printed along with their corresponding eigenvalues, where a larger eigenvalue may be taken as increased confidence in that particular frequency estimate.

Fortran
=======

ESPRIT example with noisy sinusoid
----------------------------------
Note, don't use -Ofast to avoid seg faults. There are two versions of this program, one a full accuracy using ``double complex`` numbers, and the other using ``single real`` numbers as input. The single real (4 bytes/number) runs about 4 times faster than the double complex (16 bytes/number) program.You can make only for real single precision real Fortran by::

    make real

    ./fesprit_realsp

or only double precision complex Fortran by::

    make cmpl

    ./fesprit


C
=

ESPRIT example with noisy sinusoid
----------------------------------
Here is an example of calling Fortran Esprit from C, which uses real single precision float::

  make c

  ./cesprit

C++
===
ESPRIT example with noisy sinusoid
----------------------------------
Here is an example of calling Fortran Esprit from C++, which uses real single precision float::

  make cpp

  ./cpp_esprit


Python
======

Compile Fortran ESPRIT to use from Python via f2py
--------------------------------------------------
To be able to access the Fortran Esprit from Python::

   make python

   ./test.py

See ``basic.py`` for a basic example.

If you get an ``ImportError`` complaining about gfortran 1_4, see notes at bottom of this section.


If you get ``ImportError``
---------------------------
If you're using Gfortran 5.x, you may get errors with regard to Fortran library version,
since at the moment Numpy uses Gfortran 4.x.

Try adding ``--f90exec=gfortran-4.9`` to the ``f2py3`` line in ``Makefile``.

If it still complains about library version, try::

    ln -s /usr/lib/gcc/x86_64-linux-gnu/4.9/libgfortran.so libgfortran.so.3

