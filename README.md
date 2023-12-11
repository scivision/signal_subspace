# Signal Subspace

![ci_python](https://github.com/scivision/signal_subspace/workflows/ci_python/badge.svg)
![ci_cmake](https://github.com/scivision/signal_subspace/workflows/ci_cmake/badge.svg)

[![PyPi Download stats](http://pepy.tech/badge/signal_subspace)](http://pepy.tech/project/signal_subspace)

1-D and ensemble signal subspace analysis with methods such as Esprit
and RootMusic in Fortran, C, and Python

based in part upon the
[Spectral Analysis Lib public domain code](https://github.com/vincentchoqueuse/spectral_analysis_project)

The core subspace code is written in Fortran 2008 and is called from other languages (Python, C).
Since the programs are Fortran / Python based, they should compile and run in virtually any platform from embedded to supercomputer.

```sh
cmake -B build

cmake --build build --parallel
```

If Lapack is not available, it is built automatically.

In 2023-2024, F2PY and Numpy are going through a transition of build systems.
[CMake script build the f2py bindings](https://numpy.org/doc/stable/f2py/buildtools/cmake.html)
are used to build the f2py targets that allow Python use of this library.

```sh
cmake -B build -Dpython=yes

cmake --build build --parallel
```

In the examples below, observe the frequency estimates printed along with their corresponding eigenvalues.
A larger eigenvalue is increased confidence in that particular frequency estimate.

## ESPRIT examples

All example use a noisy sinusoid.
Some are "complex" using complex numbers, while others use real numbers.

There are two versions of the complex program, one a full accuracy using `double complex` numbers, and the other using `single real` numbers as input.
The single real (4 bytes/number) runs about 4 times faster than the double complex (16 bytes/number) program.

```sh
build/f_esprit_cmpl

build/f_esprit_real
```

Call Fortran Esprit from C using real single precision float:

```sh
build/c_esprit
```

Call Fortran Esprit from C++ using real single precision float:

```sh
build/cpp_esprit
```

---

Plots comparing real vs. complex ESPRIT:

```sh
python BasicEspritExample.py
```
