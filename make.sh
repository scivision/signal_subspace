#!/bin/sh

# example of calling Fortran Esprit from C


#rm -f *.mod *.o

OPTS="-O3 -Wall -pedantic"

gfortran $OPTS -c comm.f90
gfortran $OPTS -c subspace.f90

gcc $OPTS -c RunSubspace.c -o main.o

gcc $OPTS -g subspace.o main.o -lgfortran -lm -llapack -lblas -o cesprit
