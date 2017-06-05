.. image:: https://travis-ci.org/scivision/signal_subspace.svg?branch=master
    :target: https://travis-ci.org/scivision/signal_subspace
.. image:: https://coveralls.io/repos/github/scivision/signal_subspace/badge.svg?branch=master
    :target: https://coveralls.io/github/scivision/signal_subspace?branch=master


=================
Signal Subspace
=================
1-D and ensemble signal subspace analysis with methods such as Esprit and RootMusic in Fortran, C, and Python

based in part upon the `Spectral Analysis Lib public domain code <https://github.com/vincentchoqueuse/spectral_analysis_project>`_

The core subspace code is written in Fortran 2008 and is called from other languages (Python, C).

.. contents::

Building
========

Prereqs
-------
::

    apt install libatlas-base-dev libatlas-dev liblapack-dev libblas-dev g++ gcc gfortran make cmake


For all languages (Fortran, C, C++, Python) at once, simply type::

    cd bin
    cmake ..
    make

Then you can test all languages at once from the bin/ directory by::

    ../test/test.py

If you have a need for speed, the `newly no-cost Intel MKL <https://software.intel.com/en-us/articles/free_mkl>`_ is 2-3 times faster than LAPACK.


In the examples below, you will observe the frequency estimates printed along with their corresponding eigenvalues, where a larger eigenvalue may be taken as increased confidence in that particular frequency estimate.

Fortran
=======

ESPRIT example with noisy sinusoid
----------------------------------
There are two versions of this program, one a full accuracy using ``double complex`` numbers, and the other using ``single real`` numbers as input. 
The single real (4 bytes/number) runs about 4 times faster than the double complex (16 bytes/number) program.::

    ./fespritcmpl

    ./fespritreal


C
=

ESPRIT example with noisy sinusoid
----------------------------------
Here is an example of calling Fortran Esprit from C, which uses real single precision float::

  ./cesprit

C++
===
ESPRIT example with noisy sinusoid
----------------------------------
Here is an example of calling Fortran Esprit from C++, which uses real single precision float::

  ./cppesprit


Python
======

Compile Fortran ESPRIT to use from Python via f2py
--------------------------------------------------
::

    python setup.py develop

Selftest Fortran/C/C++/Python Esprit from Python
------------------------------------------------
::

   ./test.py

Plots comparing Fortran to Python
---------------------------------
::

    ./BasicEspritExample.py

