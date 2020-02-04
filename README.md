# Signal Subspace

![ci_meson](https://github.com/scivision/signal_subspace/workflows/ci_meson/badge.svg)
![ci_cmake](https://github.com/scivision/signal_subspace/workflows/ci_cmake/badge.svg)

1-D and ensemble signal subspace analysis with methods such as Esprit
and RootMusic in Fortran, C, and Python

based in part upon the
[Spectral Analysis Lib public domain code](https://github.com/vincentchoqueuse/spectral_analysis_project)

The core subspace code is written in Fortran 2008 and is called from other languages (Python, C).

## Building

Since the programs are Fortran/Python based, they should compile and run
in virtually any environment/OS from embedded to supercomputer.

In particular, this program (Fortran, called by C or C++ optionally) works from at least

* Gfortran (GCC)
* Intel Fortran (ifort, icc, icpc)
* Flang (flang, clang, clang++)

### Prereqs

* Linux: `apt install libatlas-base-dev libatlas-dev liblapack-dev libblas-dev g++ gcc gfortran make cmake`
* Mac: `brew install lapack openblas gcc make cmake`
* Windows: recommend using Windows Subsystem for Linux.

### Install

```sh
cmake -B build

cmake --build build
```

Test the compiled libraries:

```sh
cd build
ctest -V
```

Then you can test Python calling the Fortran libraries by:

```sh
pip install -e .

pytest -v
```

In the examples below, observe the frequency estimates printed along with their corresponding eigenvalues.
A larger eigenvalue is increased confidence in that particular frequency estimate.

## Fortran

### ESPRIT example with noisy sinusoid

There are two versions of this program, one a full accuracy using `double complex` numbers, and the other using `single real` numbers as input.
The single real (4 bytes/number) runs about 4 times faster than the double complex (16 bytes/number) program.

```sh
./fespritcmpl

./fespritreal
```

### C ESPRIT example with noisy sinusoid

Here is an example of calling Fortran Esprit from C, which uses real
single precision float:

```sh
./cesprit
```

### C++ ESPRIT example with noisy sinusoid

Example of calling Fortran Esprit from C++, which uses real single precision float:

```sh
./cppesprit
```

## Python

### Compile Fortran ESPRIT to use from Python via f2py

```sh
pip install -e .
```

Selftest Fortran/C/C++/Python Esprit from Python:

```sh
pytest
```

## Notes

> /liblapack.so: undefined reference to `ATL_zgeru'

Try removing Atlas:

```sh
apt remove libatlas-base-dev
```

### Flang / Clang / Clang++

You may need

```sh
apt install libc++abi-dev
```

### Plots comparing Fortran to Python

```sh
python BasicEspritExample.py
```
