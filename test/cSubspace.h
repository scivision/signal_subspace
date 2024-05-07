// these are Fortran procedures

#ifdef __cplusplus
extern "C" {
#else
#include <stdbool.h>
#endif

bool fircircfilter(float [], const int, float [], const int, float []);

void signoise_r(const float*, const float*, const float, const int, float []);

void esprit_r(float [], const int, const int, const int, const float, float [], float []);

#ifdef __cplusplus
}
#endif
