#!/bin/bash

# tests all the programs for "OK" result

cd bin
./fespritcmpl && echo "Fortran Complex OK" || echo "Fortran Complex FAIL"
./fespritreal && echo "Fortran Real OK" || echo "Fortran Real FAIL"
./cesprit && echo "ANSI C OK" || echo "ANSI C FAIL"
./cppesprit  && echo "C++ OK" || echo "C++ FAIL"

cd ..
./test/test.py && echo "Python OK" || echo "Python FAIL"
