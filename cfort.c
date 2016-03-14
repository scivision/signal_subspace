#include <stdio.h>

int main() {
 int i=12345;
 float f;
 extern void int2float_(int *i, float *f);
 int2float_(&i, &f);
 printf("%f",f);
}

