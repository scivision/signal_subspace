.. image:: https://travis-ci.org/scienceopen/spectral_analysis.svg?branch=master
    :target: https://travis-ci.org/scienceopen/spectral_analysis

=================
spectral_analysis
=================
1-D and ensemble signal analysis with subspace methods such as Esprit and RootMusic in Fortran, C, and Python

based in part upon the `Spectral Analysis Lib public domain code <https://github.com/vincentchoqueuse/spectral_analysis_project>`_

The core subspace code is written in Fortran 2008 and is called from other languages (Python, C).

.. contents::

Building
========

Prereqs
-------
::

    sudo apt-get install libatlas-base-dev libatlas-dev liblapack-dev libblas-dev g++ gcc gfortran make


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

   make pythonreal pythoncmpl
  
   ./test.py

See ``basic.py`` for a basic example.

