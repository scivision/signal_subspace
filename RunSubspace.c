#include <stdio.h>
#include <complex.h>

extern void __subspace_MOD_esprit(complex double [], int *, int *, int *, double *, double [], double []);

int main () {
 int N=12;
 int L=2;
 int M=6;
 double fs=48000.;

// this is a noisy 21234.5 Hz sinusoid, extreme case where we have very few samples to build up the noise estimate. Normally you would use say 10-100x as many samples. 
 double complex x[12]={1.0004620 - I*0.0008895,  -0.9338329 + I*0.0004178,  0.7494963 + I*0.0010474,  -0.4654616 + I*0.0008352,  0.1242105 - I*0.0000312,   0.2369377 + I*0.0013630,-0.5662766 + I*0.0000239,   0.8222365 - I*0.0004521,  -0.9696022 - I*0.0004094, 0.9948683 + I*0.0004826,  -0.8875562 + I*0.0003774,   0.6680975 - I*0.0008353};

//---------------------------------
double tones[L], sigma[L];

// if we pass the reference to the first array address, the rest of the array will follow (tones,sigma)
__subspace_MOD_esprit(&x[0], &N, &L, &M, &fs, &tones[0], &sigma[0]);

printf("tones: %f %f\n",tones[0],tones[1]);
printf("sigma: %f %f",sigma[0],sigma[1]);

}

