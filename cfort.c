#include <stdio.h>

extern void int2float_( int *, float *);

int main() {
 int i=12345;
 float f;
 int2float_(&i, &f);
 printf("%f",f);
}

