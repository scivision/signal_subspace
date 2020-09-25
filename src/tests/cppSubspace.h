// these are Fortran procedures

extern "C" void signoise_r(const float*, const float*, const float*, int*, float []);

extern "C" void fircircfilter(float [], int*,float [],int*,float [],bool*);

extern "C" void esprit_r(float [], int*, int*, int*, const float*, float [], float []);
