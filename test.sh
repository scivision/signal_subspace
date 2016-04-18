#!/bin/bash

# tests all the programs for "OK" result

cd bin
./fespritcmpl && echo "Fortran Complex OK" || echo "Fortran Complex FAIL"
echo
./fespritreal && echo "Fortran Real OK" || echo "Fortran Real FAIL"
echo
./cesprit && echo "ANSI C OK" || echo "ANSI C FAIL"
echo
./cppesprit  && echo "C++ OK" || echo "C++ FAIL"
echo

cd ..
./test/test.py && echo "Python OK" || echo "Python FAIL"
