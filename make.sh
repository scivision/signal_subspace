#!/bin/sh

# example of calling Fortran Esprit from C


rm -f *.mod *.o

gfortran -O0 -c comm.f90
gfortran -O0 -c subspace.f90

gcc -O0 -c RunSubspace.c -o main.o

gcc -O0 -g subspace.o main.o -lgfortran -lm -llapack -lblas -o cesprit
