.. image:: https://travis-ci.org/scivision/signal_subspace.svg?branch=master
    :target: https://travis-ci.org/scivision/signal_subspace
    
.. image:: https://coveralls.io/repos/github/scivision/signal_subspace/badge.svg?branch=master
    :target: https://coveralls.io/github/scivision/signal_subspace?branch=master

.. image:: https://api.codeclimate.com/v1/badges/5f2cff37394a699b5e7d/maintainability
   :target: https://codeclimate.com/github/scivision/signal_subspace/maintainability
   :alt: Maintainability


=================
Signal Subspace
=================
1-D and ensemble signal subspace analysis with methods such as Esprit and RootMusic in Fortran, C, and Python

based in part upon the `Spectral Analysis Lib public domain code <https://github.com/vincentchoqueuse/spectral_analysis_project>`_

The core subspace code is written in Fortran 2008 and is called from other languages (Python, C).

.. contents::

Building
========

Since the programs are Fortran/Python based, they should compile and run in virtually any environment/OS from embedded to supercomputer.

Prereqs
-------
If you don't already have Numpy::

    pip install numpy

Linux
~~~~~
::

    apt install libatlas-base-dev libatlas-dev liblapack-dev libblas-dev g++ gcc gfortran make cmake

Mac
~~~
::

    brew install lapack openblas gcc make cmake
    
Windows
~~~~~~~
Recommend using Windows Subsystem for Linux.
    
Install
-------

.. code:: bash

    cd bin
    cmake ..
    make

Test the compiled libraries::

    make test    


Note: for those using the Flang/Clang/LLVM compilers, you may need to tell the executable where to find ``libflang.so`` by something like:

.. code:: bash

    LD_LIBRARY_PATH=$HOME/miniconda3/lib ./cppesprit
    
Then you can test Python calling the Fortran libraries by::

   pip install -e .

   pytest -v

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

    pip install -e .

Selftest Fortran/C/C++/Python Esprit from Python
------------------------------------------------
::

   ./test.py

Plots comparing Fortran to Python
---------------------------------
::

    ./BasicEspritExample.py

