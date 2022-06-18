// these are Fortran procedures

#ifdef __cplusplus
extern "C" {
#else
#include <stdbool.h>
#endif

extern void fircircfilter(float [], int*,float [],int*,float [], bool*);

extern void signoise_r(const float*, const float*, const float*, int*, float []);

extern void esprit_r(float [], int*, int*, int*, const float*, float [], float []);

#ifdef __cplusplus
}
#endif
