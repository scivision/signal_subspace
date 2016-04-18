#include <stdio.h>
#include <stdlib.h>
#include <math.h>

extern void __signals_MOD_signoise(const float*, const float*, const float*, int*, float []);

extern void __filters_MOD_fircircfilter(float [], int*,float [],int*,float [], int*);

extern void __subspace_MOD_esprit(float [], int*, int*, int*, const float*, float [], float []);


int main () {
printf("ANSI C Esprit\n");

int Ns=1024;
int Ntone=2;
int M=Ns/2;
const float fs=48000.;
//------- noisy signal generation ----------------
const float snr = 60.; // dB, arbitrary
const float f0 = (float)12345.6; //arbitrary

float * x;
x = malloc((size_t)Ns*sizeof(float));
__signals_MOD_signoise(&fs, &f0, &snr, &Ns, &x[0]);

//---- signal estimation -----------------------------
float * tones = malloc((size_t)Ntone*sizeof(float));
float * sigma = malloc((size_t)Ntone*sizeof(float));

// if we pass the reference to the first array address, the rest of the array will follow (tones,sigma)
__subspace_MOD_esprit(&x[0], &Ns, &Ntone, &M, &fs, &tones[0], &sigma[0]);

free(x);

printf("estimated tone freq [Hz]: ");
for (int i=0; i<Ntone; i++) printf("%f ",tones[i]);

printf("\nwith sigma:               ");
for (int i=0; i<Ntone; i++) printf("%f ",sigma[i]);
printf("\n");

if (fabsf(tones[0]-f0)>0.0001*f0){
    fprintf(stderr,"E: failed to meet tolerance\n");
    return EXIT_FAILURE;
}
else{
    printf("OK\n");
    return EXIT_SUCCESS;
}

} // main

