#!/bin/bash

# tests all the programs for "OK" result

make -s clean 
make -s &> /dev/null

[[ ./fesprit ]] && echo "Fortran Complex OK" || echo "Fortran Complex FAIL"
[[ ./fesprit_realsp ]] && echo "Fortran Real OK" || echo "Fortran Real FAIL"
[[ ./cesprit ]] && echo "ANSI C OK" || echo "ANSI C FAIL"
[[ ./cpp_esprit ]] && echo "C++ OK" || echo "C++ FAIL"
[[ ./test/test.py ]] && echo "Python OK" || echo "Python FAIL"
